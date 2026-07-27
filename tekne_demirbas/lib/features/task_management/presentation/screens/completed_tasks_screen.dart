import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ancyra_sailing/common_widgets/async_value_ui.dart';
import 'package:ancyra_sailing/common_widgets/async_value_widget.dart';
import 'package:ancyra_sailing/features/authentication/data/auth_repository.dart';
import 'package:ancyra_sailing/features/room_management/presentation/providers/selected_room_provider.dart';
import 'package:ancyra_sailing/features/task_management/data/firestore_repository.dart';
import 'package:ancyra_sailing/features/task_management/domain/task.dart';
import 'package:ancyra_sailing/features/task_management/presentation/providers/task_filter_provider.dart';
import 'package:ancyra_sailing/features/task_management/presentation/widgets/task_item.dart';
import 'package:ancyra_sailing/features/task_management/presentation/widgets/filter_bar.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

class CompletedTasksScreen extends ConsumerWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomId = ref.watch(selectedRoomProvider);
    
    if (roomId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.meeting_room, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(AppTranslations.t(context, 'pleaseSelectRoom')),
          ],
        ),
      );
    }

    final completeTaskAsyncValue = ref.watch(filteredCompletedTasksProvider(roomId));

    ref.listen<AsyncValue>(loadTasksProvider(roomId), (_, state) {
      state.showAlertDialogOnError(context);
    });

    return Container(
      decoration: const BoxDecoration(
        gradient: Appstyles.lightOceanGradient,
      ),
      child: Column(
        children: [
          FilterBar(filterControllerProvider: completedTasksFilterControllerProvider),
          Expanded(
            child: AsyncValueWidget<List<Task>>(
              value: completeTaskAsyncValue,
              data: (tasks) {
                return tasks.isEmpty
                    ? Center(child: Text(AppTranslations.t(context, 'noTasksYet')))
                    : ListView.separated(
                        itemBuilder: (ctx, index) {
                          final task = tasks[index];

                          return TaskItem(task: task);
                        },
                        separatorBuilder: (ctx, height) =>
                            const Divider(height: 2, color: Colors.blue),
                        itemCount: tasks.length,
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
