import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ancyra_sailing/common_widgets/adaptive_task_list.dart';
import 'package:ancyra_sailing/common_widgets/async_value_ui.dart';
import 'package:ancyra_sailing/common_widgets/async_value_widget.dart';
import 'package:ancyra_sailing/features/room_management/presentation/providers/selected_room_provider.dart';
import 'package:ancyra_sailing/features/task_management/data/firestore_repository.dart';
import 'package:ancyra_sailing/features/task_management/domain/task.dart';
import 'package:ancyra_sailing/features/task_management/presentation/providers/task_filter_provider.dart';
import 'package:ancyra_sailing/features/task_management/presentation/widgets/task_item.dart';
import 'package:ancyra_sailing/features/task_management/presentation/widgets/filter_bar.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

class IncompleteTasksScreen extends ConsumerWidget {
  const IncompleteTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
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

    final completeTaskAsyncValue =
        ref.watch(filteredIncompletedTasksProvider(roomId));

    ref.listen<AsyncValue>(loadTasksProvider(roomId), (_, state) {
      state.showAlertDialogOnError(context);
    });

    return Container(
      decoration: const BoxDecoration(
        gradient: Appstyles.lightOceanGradient,
      ),
      child: Column(
        children: [
          ResponsiveCenter(
            maxWidth: SizeConfig.contentMaxWidth,
            child: FilterBar(
              filterControllerProvider:
                  incompletedTasksFilterControllerProvider,
            ),
          ),
          Expanded(
            child: AsyncValueWidget<List<Task>>(
              value: completeTaskAsyncValue,
              data: (tasks) {
                return AdaptiveTaskList(
                  itemCount: tasks.length,
                  empty: Center(
                    child: Text(AppTranslations.t(context, 'noTasksYet')),
                  ),
                  itemBuilder: (ctx, index) => TaskItem(task: tasks[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
