import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ancyra_sailing/features/task_management/data/firestore_repository.dart';
import 'package:ancyra_sailing/features/task_management/data/storage_repository.dart';
import 'package:ancyra_sailing/features/task_management/domain/task.dart';

part 'firestore_controller.g.dart';

@Riverpod(keepAlive: true)
class FirestoreController extends _$FirestoreController {
  @override
  FutureOr<void> build() {}

  Future<void> addTask({
    required Task task,
    required String userId,
    required String roomId,
    List<String>? imageUrls,
    String? videoUrl,
  }) async {
    state = const AsyncLoading();
    final fireStoreRepository = ref.read(firestoreRepositoryProvider);
    
    try {
      // Önce task'ı oluştur ve ID'yi al
      final taskId = await fireStoreRepository.addTask(
        task: task, 
        userId: userId,
        roomId: roomId,
      );
      
      // Medya varsa task'ı güncelle
      if (imageUrls != null || videoUrl != null) {
        final updatedTask = task.copyWith(
          id: taskId,
          imageUrls: imageUrls ?? task.imageUrls,
          videoUrl: videoUrl ?? task.videoUrl,
        );
        await fireStoreRepository.updateTask(
          task: updatedTask,
          taskId: taskId,
          userId: userId,
        );
      }
      
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTask({
    required Task task,
    required String userId,
    required String taskId,
    List<String> deletedImageUrls = const [],
    String? deletedVideoUrl,
  }) async {
    state = const AsyncLoading();
    final fireStoreRepository = ref.read(firestoreRepositoryProvider);
    final storageRepository = ref.read(storageRepositoryProvider);

    try {
      // Önce Firestore'u güncelle (DB güncellemesi başarısız olursa dosya silmeyelim)
      await fireStoreRepository.updateTask(
        task: task,
        taskId: taskId,
        userId: userId,
      );

      // Sonra Storage'dan kaldırılan medyaları best-effort sil
      final urlsToDelete = <String>{
        ...deletedImageUrls,
        if (deletedVideoUrl != null && deletedVideoUrl.isNotEmpty)
          deletedVideoUrl,
      };

      for (final url in urlsToDelete) {
        try {
          await storageRepository.deleteFile(url);
        } catch (e) {
          // Storage silme hatası güncelleme işlemini durdurmaz
          // ignore: avoid_print
          print('Storage dosyası silinirken hata: $e');
        }
      }

      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteTask({required String taskId}) async {
    if (!ref.mounted) return;
    
    state = const AsyncLoading();
    final fireStoreRepository = ref.read(firestoreRepositoryProvider);
    final storageRepository = ref.read(storageRepositoryProvider);

    try {
      await fireStoreRepository.deleteTask(taskId: taskId);

      try {
        await storageRepository.deleteTaskFiles(taskId);
      } catch (e) {
        // ignore: avoid_print
        print('Storage dosyaları silinirken hata: $e');
      }

      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
