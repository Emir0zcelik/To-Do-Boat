const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.notifyRoomOnNewTask = onDocumentCreated("tasks/{taskId}", async (event) => {
  const task = event.data?.data();
  if (!task?.roomId) {
    return;
  }

  const db = getFirestore();
  const roomSnap = await db.collection("rooms").doc(task.roomId).get();
  if (!roomSnap.exists) {
    return;
  }

  const room = roomSnap.data();
  const memberIds = room.memberIds || [];
  const roomName = room.name || "Oda";
  const createdBy = task.createdBy || "";

  const recipientIds = memberIds.filter((id) => id !== createdBy);
  if (recipientIds.length === 0) {
    return;
  }

  const tokens = new Set();
  for (const userId of recipientIds) {
    const userSnap = await db.collection("users").doc(userId).get();
    if (!userSnap.exists) continue;

    const userData = userSnap.data();
    const userTokens = userData.fcmTokens || [];
    for (const token of userTokens) {
      if (token) tokens.add(token);
    }
    if (userData.fcmToken) {
      tokens.add(userData.fcmToken);
    }
  }

  const tokenList = [...tokens];
  if (tokenList.length === 0) {
    return;
  }

  let creatorName = "Bir kullanıcı";
  if (createdBy) {
    const creatorSnap = await db.collection("users").doc(createdBy).get();
    if (creatorSnap.exists) {
      creatorName = creatorSnap.data().displayName || creatorName;
    }
  }

  const taskTitle = task.title || task.description || "Yeni görev";
  const body =
    task.description && task.description !== taskTitle
      ? task.description.substring(0, 120)
      : `${creatorName} yeni bir görev ekledi`;

  const message = {
    notification: {
      title: `${roomName}: Yeni görev`,
      body,
    },
    data: {
      type: "new_task",
      roomId: task.roomId,
      taskId: event.params.taskId,
    },
    tokens: tokenList,
  };

  const response = await getMessaging().sendEachForMulticast(message);

  if (response.failureCount > 0) {
    const invalidTokens = [];
    response.responses.forEach((res, index) => {
      if (!res.success) {
        invalidTokens.push(tokenList[index]);
      }
    });

    for (const userId of recipientIds) {
      const userRef = db.collection("users").doc(userId);
      const userSnap = await userRef.get();
      if (!userSnap.exists) continue;

      const userData = userSnap.data();
      const currentTokens = userData.fcmTokens || [];
      const cleaned = currentTokens.filter((t) => !invalidTokens.includes(t));
      if (cleaned.length !== currentTokens.length) {
        await userRef.update({ fcmTokens: cleaned });
      }
    }
  }
});
