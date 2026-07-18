import 'package:cloud_firestore/cloud_firestore.dart';

class FcmTokenRepository {
  FcmTokenRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> saveToken(String userId, String token) async {
    if (token.isEmpty) return;

    await _firestore.collection('users').doc(userId).set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> removeToken(String userId, String token) async {
    if (token.isEmpty) return;

    await _firestore.collection('users').doc(userId).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}
