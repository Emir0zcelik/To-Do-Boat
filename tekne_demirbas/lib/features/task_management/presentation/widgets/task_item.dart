import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ancyra_sailing/features/authentication/data/auth_repository.dart';
import 'package:ancyra_sailing/features/room_management/data/room_repository.dart';
import 'package:ancyra_sailing/features/room_management/presentation/providers/permission_provider.dart';
import 'package:ancyra_sailing/features/task_management/data/firestore_repository.dart';
import 'package:ancyra_sailing/features/task_management/data/storage_repository.dart';
import 'package:ancyra_sailing/features/task_management/domain/task.dart';
import 'package:ancyra_sailing/features/task_management/presentation/firestore_controller.dart';
import 'package:ancyra_sailing/features/task_management/presentation/providers/boat_type_provider.dart' as boat_provider;
import 'package:ancyra_sailing/features/task_management/presentation/providers/task_type_provider.dart' as task_provider;
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';
import 'package:video_player/video_player.dart';

class TaskItem extends ConsumerStatefulWidget {
  const TaskItem({super.key, required this.task});
  final Task task;

  @override
  ConsumerState<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<TaskItem> {
  final ImagePicker _picker = ImagePicker();
  
  void _editTask() {
    final titleController = TextEditingController(text: widget.task.title);
    final descriptionController = TextEditingController(text: widget.task.description);
    String? selectedBoatType = widget.task.boatType;
    String? selectedTaskType = widget.task.taskType;
    
    // Medya için state değişkenleri
    final List<String> existingImageUrls = List<String>.from(widget.task.imageUrls);
    String? existingVideoUrl = widget.task.videoUrl;
    final List<File> newImages = [];
    File? newVideo;
    VideoPlayerController? newVideoController;

    showDialog(
      context: context,
      builder: (ctx) {
        // Dialog kapatıldığında video controller'ı temizle
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) {
              newVideoController?.dispose();
            }
          },
          child: Consumer(
            builder: (context, ref, _) {
          final boatTypeAsync = ref.watch(boat_provider.boatTypesProvider);
          final taskTypeAsync = ref.watch(task_provider.taskTypesProvider);

          return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.green, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    AppTranslations.t(context, 'editTask'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Görev Adı
                      Text(
                        AppTranslations.t(context, 'taskName'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: AppTranslations.t(context, 'taskNameHint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.title),
                        ),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      // Görev Tanımı
                      Text(
                        AppTranslations.t(context, 'taskDesc'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: AppTranslations.t(context, 'taskDescHint'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          prefixIcon: const Icon(Icons.description),
                        ),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      // Tekne Türü
                      Text(
                        AppTranslations.t(context, 'boatTypeLabel'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      boatTypeAsync.when(
                        data: (boats) {
                          final boatNames = boats.map((b) => b.name).toList();
                          return DropdownButtonFormField<String>(
                            value: selectedBoatType,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              prefixIcon: const Icon(Icons.directions_boat),
                            ),
                            items: boatNames.map((name) {
                              return DropdownMenuItem(
                                value: name,
                                child: Text(
                                  name,
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedBoatType = value;
                              });
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text(
                          'Tekne türleri yüklenemedi',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // İş Türü
                      Text(
                        AppTranslations.t(context, 'taskType'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      taskTypeAsync.when(
                        data: (taskTypes) {
                          final taskTypeNames = taskTypes.map((t) => t.name).toList();
                          final effectiveValue = selectedTaskType ?? '';
                          final validValues = ['', ...taskTypeNames];
                          final value = validValues.contains(effectiveValue) ? effectiveValue : '';
                          return DropdownButtonFormField<String>(
                            value: value,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              prefixIcon: const Icon(Icons.work),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text(
                                  'İş türü seçme (opsiyonel)',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                              ...taskTypeNames.map((name) {
                                return DropdownMenuItem(
                                  value: name,
                                  child: Text(
                                    name,
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedTaskType = value ?? '';
                              });
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text(
                          'İş türleri yüklenemedi',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Medya Ekleme Bölümü
                      Text(
                        AppTranslations.t(context, 'media'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              final type = await showModalBottomSheet<String>(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.photo, color: Appstyles.primaryBlue),
                                          title: const Text("Fotoğraf", style: TextStyle(color: Colors.black87)),
                                          onTap: () => Navigator.pop(context, "image"),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.videocam, color: Appstyles.primaryBlue),
                                          title: const Text("Video", style: TextStyle(color: Colors.black87)),
                                          onTap: () => Navigator.pop(context, "video"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                              
                              if (type == "image") {
                                final XFile? picked = await _picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 70,
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    newImages.add(File(picked.path));
                                  });
                                }
                              } else if (type == "video") {
                                final XFile? picked = await _picker.pickVideo(source: ImageSource.camera);
                                if (picked != null) {
                                  newVideoController?.dispose();
                                  final file = File(picked.path);
                                  final controller = VideoPlayerController.file(file);
                                  await controller.initialize();
                                  setDialogState(() {
                                    newVideo = file;
                                    newVideoController = controller;
                                  });
                                }
                              }
                            },
                          ),
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.photo_library),
                            onPressed: () async {
                              final type = await showModalBottomSheet<String>(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.photo, color: Appstyles.primaryBlue),
                                          title: const Text("Fotoğraf", style: TextStyle(color: Colors.black87)),
                                          onTap: () => Navigator.pop(context, "image"),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.videocam, color: Appstyles.primaryBlue),
                                          title: const Text("Video", style: TextStyle(color: Colors.black87)),
                                          onTap: () => Navigator.pop(context, "video"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                              
                              if (type == "image") {
                                final XFile? picked = await _picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 70,
                                );
                                if (picked != null) {
                                  setDialogState(() {
                                    newImages.add(File(picked.path));
                                  });
                                }
                              } else if (type == "video") {
                                final XFile? picked = await _picker.pickVideo(source: ImageSource.gallery);
                                if (picked != null) {
                                  newVideoController?.dispose();
                                  final file = File(picked.path);
                                  final controller = VideoPlayerController.file(file);
                                  await controller.initialize();
                                  setDialogState(() {
                                    newVideo = file;
                                    newVideoController = controller;
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),

                      // Mevcut resimler (URL) - kaldırma seçeneği
                      if (existingImageUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Mevcut Fotoğraflar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: existingImageUrls.length,
                            itemBuilder: (context, index) {
                              final url = existingImageUrls[index];
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Appstyles.lightBlue, width: 1.5),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Appstyles.lightGray,
                                          child: const Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Fotoğrafı kaldır?'),
                                            content: const Text(
                                              'Bu fotoğraf görevden kaldırılacak ve güncelle dediğinizde depolamadan (Storage) da silinecek.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(false),
                                                child: const Text('İptal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(ctx).pop(true),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                child: const Text('Sil', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          setDialogState(() {
                                            existingImageUrls.removeAt(index);
                                          });
                                        }
                                      },
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],

                      // Mevcut video (URL) - kaldırma seçeneği
                      if (existingVideoUrl != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Mevcut Video',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setDialogState(() {
                                  existingVideoUrl = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                      
                      // Yeni eklenen resimler
                      if (newImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: newImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(newImages[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Fotoğrafı kaldır?'),
                                            content: const Text(
                                              'Bu fotoğraf görevden kaldırılacak.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(false),
                                                child: const Text('İptal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(ctx).pop(true),
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                child: const Text('Sil', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          setDialogState(() {
                                            newImages.removeAt(index);
                                          });
                                        }
                                      },
                                      child: const CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      
                      // Yeni eklenen video
                      if (newVideoController != null)
                        Column(
                          children: [
                            AspectRatio(
                              aspectRatio: newVideoController!.value.aspectRatio,
                              child: VideoPlayer(newVideoController!),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                newVideoController?.dispose();
                                setDialogState(() {
                                  newVideoController = null;
                                  newVideo = null;
                                });
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                Consumer(
                  builder: (context, ref, _) {
                    final canEdit = ref.watch(canEditTaskProvider);
                    final canDelete = ref.watch(canDeleteTaskProvider);
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sil Butonu - sadece canDelete varsa göster
                        if (canDelete)
                          TextButton.icon(
                            onPressed: () {
                              context.pop();
                              _showDeleteConfirmation();
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              AppTranslations.t(context, 'delete'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        // İptal ve Güncelle Butonları
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                AppTranslations.t(context, 'cancel'),
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Güncelle Butonu - sadece canEdit varsa göster
                            if (canEdit)
                              ElevatedButton(
                          onPressed: () async {
                            final descriptionText = descriptionController.text.trim();
                            if (descriptionText.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                          content: const Text(
                            'Görev açıklaması boş olamaz',
                            style: TextStyle(color: Colors.white),
                          ),
                                  backgroundColor: Colors.red.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                                  ),
                                ),
                              );
                              return;
                            }

                            // Silinen medyaları tespit et (mevcutlardan kaldırılanlar)
                            final deletedImageUrls = widget.task.imageUrls
                                .where((url) => !existingImageUrls.contains(url))
                                .toList();

                            // Medya varsa yükle
                            List<String>? newImageUrls;
                            String? newVideoUrl;
                            
                            if (newImages.isNotEmpty || newVideo != null) {
                              final storageRepo = ref.read(storageRepositoryProvider);
                              final taskId = widget.task.id;
                              
                              // Yeni resimleri yükle
                              if (newImages.isNotEmpty) {
                                try {
                                  newImageUrls = await storageRepo.uploadImages(newImages, taskId);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Resimler yüklenirken hata: $e',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red.shade400,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                              
                              // Yeni videoyu yükle
                              if (newVideo != null) {
                                try {
                                  newVideoUrl = await storageRepo.uploadVideo(newVideo!, taskId);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Video yüklenirken hata: $e',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red.shade400,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                            }
                            
                            // Mevcut medya URL'lerini al ve yeni medyalarla birleştir
                            List<String> finalImageUrls = List<String>.from(existingImageUrls);
                            if (newImageUrls != null) {
                              finalImageUrls.addAll(newImageUrls);
                            }
                            
                            String? finalVideoUrl = existingVideoUrl;
                            if (newVideoUrl != null) {
                              finalVideoUrl = newVideoUrl;
                            }

                            // Video değiştiyse (silindiyse veya yenisi yüklendiyse) eskiyi sil
                            final String? deletedVideoUrl =
                                (widget.task.videoUrl != null && widget.task.videoUrl != finalVideoUrl)
                                    ? widget.task.videoUrl
                                    : null;

                            // Başlığı açıklamanın ilk 50 karakteri olarak oluştur
                            final title = descriptionText.length > 50
                                ? '${descriptionText.substring(0, 50).trimRight()}…'
                                : descriptionText;

                            final newTask = Task(
                              id: widget.task.id,
                              title: title,
                              description: descriptionText,
                              taskType: selectedTaskType ?? widget.task.taskType,
                              boatType: selectedBoatType ?? widget.task.boatType,
                              createdBy: widget.task.createdBy,
                              roomId: widget.task.roomId,
                              isComplete: widget.task.isComplete,
                              date: DateTime.now().toString(),
                              imageUrls: finalImageUrls,
                              videoUrl: finalVideoUrl,
                            );

                            // Dialog'u hemen kapat
                            if (context.mounted) {
                              context.pop();
                            }
                            
                            // Video controller'ı temizle
                            newVideoController?.dispose();
                            
                            // Görevi güncelle
                            await ref
                                .read(firestoreControllerProvider.notifier)
                                .updateTask(
                                  task: newTask,
                                  userId: widget.task.createdBy,
                                  taskId: widget.task.id,
                                  deletedImageUrls: deletedImageUrls,
                                  deletedVideoUrl: deletedVideoUrl,
                                );
                            
                            // Başarı mesajını göster
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Görev başarıyla güncellendi!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green.shade400,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                                child: Text(
                                  AppTranslations.t(context, 'update'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: const Icon(Icons.warning, color: Colors.red, size: 50),
        title: Text(
          AppTranslations.t(context, 'deleteTask'),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: Text(
          AppTranslations.t(context, 'deleteTaskConfirm'),
          style: const TextStyle(color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        actions: [
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppTranslations.t(context, 'cancel'), style: const TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(firestoreControllerProvider.notifier)
                  .deleteTask(taskId: widget.task.id);
              context.pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              AppTranslations.t(context, 'delete'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetail() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppTranslations.t(context, 'barrierClose'),
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) {
        final mq = MediaQuery.of(ctx);
        final dialogWidth = mq.size.width * 0.96;
        final maxHeight = mq.size.height * 0.88;
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: Appstyles.white,
              borderRadius: BorderRadius.circular(Appstyles.borderRadiusLarge),
              boxShadow: Appstyles.strongShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sağ üst - tarih tagi
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 20, left: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _DateTimeTag(dateTime: widget.task.dateTime, color: Appstyles.darkBlue),
                  ),
                ),
                const SizedBox(height: 8),
                // İçerik: Açıklama -> Medya -> Etiketler
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Açıklama
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                            color: Appstyles.lightGray,
                            borderRadius: BorderRadius.circular(Appstyles.borderRadiusMedium),
                            border: Border.all(
                              color: Appstyles.lightBlue,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.task.description,
                            style: TextStyle(
                              fontSize: 17,
                              height: 1.65,
                              color: Appstyles.textDark,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Medya - Resimler
                        if (widget.task.imageUrls.isNotEmpty) ...[
                          Text(
                            'Resimler',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Appstyles.textDark,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.task.imageUrls.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (imgCtx) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Stack(
                                          children: [
                                            InteractiveViewer(
                                              child: Image.network(
                                                widget.task.imageUrls[index],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                icon: const Icon(Icons.close, color: Appstyles.white),
                                                onPressed: () => Navigator.of(imgCtx).pop(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 220,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                                      border: Border.all(color: Appstyles.lightBlue, width: 2),
                                      boxShadow: Appstyles.softShadow,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                                      child: Image.network(
                                        widget.task.imageUrls[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Medya - Video
                        if (widget.task.videoUrl != null) ...[
                          Text(
                            'Video',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Appstyles.textDark,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                              border: Border.all(color: Appstyles.lightBlue, width: 2),
                              boxShadow: Appstyles.softShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: VideoPlayerWidget(
                                  videoUrl: widget.task.videoUrl!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Etiketler
                        Text(
                          'Etiketler',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Appstyles.textDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                          decoration: BoxDecoration(
                            color: Appstyles.lightGray.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                          ),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                            _Tag(
                              text: widget.task.boatType,
                              color: Appstyles.secondaryBlue,
                            ),
                            if (widget.task.taskType.isNotEmpty)
                              _Tag(
                                text: widget.task.taskType,
                                color: Appstyles.primaryBlue,
                              ),
                            Consumer(
                              builder: (context, ref, _) {
                                final isEmail = widget.task.createdBy.contains('@');
                                final displayNameAsync = isEmail
                                    ? ref.watch(loadUserDisplayNameByEmailProvider(widget.task.createdBy))
                                    : ref.watch(loadUserDisplayNameProvider(widget.task.createdBy));
                                return displayNameAsync.when(
                                  data: (displayName) => _Tag(
                                    text: displayName ?? (isEmail ? widget.task.createdByUsername : widget.task.createdBy),
                                    color: Appstyles.accentBlue,
                                  ),
                                  loading: () => _Tag(
                                    text: 'Yükleniyor...',
                                    color: Appstyles.accentBlue,
                                  ),
                                  error: (_, __) => _Tag(
                                    text: isEmail ? widget.task.createdByUsername : widget.task.createdBy,
                                    color: Appstyles.accentBlue,
                                  ),
                                );
                              },
                            ),
                            _Tag(
                              text: widget.task.isComplete ? 'Tamamlandı' : 'Devam Ediyor',
                              color: widget.task.isComplete ? Appstyles.secondaryBlue : Colors.red.shade300,
                            ),
                          ],
                        ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Sağ alt - kapat butonu
                Container(
                  padding: const EdgeInsets.only(top: 12, bottom: 16, left: 24, right: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Appstyles.lightBlue.withOpacity(0.8), width: 1),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Appstyles.textLight, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return GestureDetector(
      onTap: _showTaskDetail,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Appstyles.borderRadiusMedium),
          gradient: widget.task.isComplete 
              ? LinearGradient(
                  colors: [Appstyles.lightBlue.withOpacity(0.3), Appstyles.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: widget.task.isComplete ? null : Appstyles.white,
          boxShadow: Appstyles.softShadow,
          border: Border.all(
            color: widget.task.isComplete 
                ? Appstyles.secondaryBlue.withOpacity(0.3)
                : Appstyles.lightBlue,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.task.taskType.isNotEmpty
                    ? '${widget.task.boatType} - ${widget.task.taskType}'
                    : widget.task.boatType,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final canEdit = ref.watch(canEditTaskProvider);
                      final canDelete = ref.watch(canDeleteTaskProvider);
                      if (!canEdit && !canDelete) {
                        return const SizedBox.shrink();
                      }
                      return PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 22,
                      offset: const Offset(0, 36),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                        minimumSize: WidgetStateProperty.all(const Size(28, 28)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.more_horiz, color: Appstyles.primaryBlue, size: 22),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editTask();
                        } else if (value == 'delete') {
                          _showDeleteConfirmation();
                        }
                      },
                      itemBuilder: (context) => [
                        if (canEdit)
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(AppTranslations.t(context, 'edit')),
                          ),
                        if (canDelete)
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(AppTranslations.t(context, 'delete')),
                          ),
                      ],
                    );
                  },
                ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final canEdit = ref.watch(canEditTaskProvider);
                    return Transform.translate(
                      offset: const Offset(0, -6),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {},
                        child: Transform.scale(
                          scale: 2.0,
                          child: Checkbox(
                            value: widget.task.isComplete,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            activeColor: Appstyles.secondaryBlue,
                            checkColor: Appstyles.white,
                            onChanged: (bool? value) {
                              if (value == null) return;
                              if (!canEdit) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Görev durumunu değiştirme yetkiniz yok. Sadece görüntüleme yetkiniz var.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red.shade400,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(Appstyles.borderRadiusSmall),
                                    ),
                                  ),
                                );
                                return;
                              }
                              ref.read(firestoreRepositoryProvider).updateTaskCompletion(
                                    taskId: widget.task.id,
                                    isComplete: value,
                                  );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            ),
          ],
      ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DateTimeTag extends StatelessWidget {
  const _DateTimeTag({super.key, required this.dateTime, required this.color});

  final DateTime? dateTime;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dt = dateTime;
    if (dt == null) {
      return _Tag(text: '', color: color);
    }

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    final dateTimeText = '$day/$month/$year $hour:$minute';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        dateTimeText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.addListener(() {
          if (mounted) {
            setState(() {
              _isPlaying = _controller!.value.isPlaying;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          if (!_isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
        ],
      ),
    );
  }
}
