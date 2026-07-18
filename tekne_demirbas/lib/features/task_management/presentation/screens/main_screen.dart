import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ancyra_sailing/features/authentication/data/auth_repository.dart';
import 'package:ancyra_sailing/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:ancyra_sailing/features/room_management/data/room_repository.dart';
import 'package:ancyra_sailing/features/room_management/domain/permission.dart';
import 'package:ancyra_sailing/features/room_management/domain/room.dart';
import 'package:ancyra_sailing/features/room_management/presentation/providers/selected_room_provider.dart';
import 'package:ancyra_sailing/features/task_management/presentation/screens/add_tasks_screen.dart';
import 'package:ancyra_sailing/features/task_management/presentation/screens/completed_tasks_screen.dart';
import 'package:ancyra_sailing/features/task_management/presentation/screens/incomplete_tasks_screen.dart';
import 'package:ancyra_sailing/features/task_management/presentation/widgets/room_management_dialog.dart';
import 'package:ancyra_sailing/features/task_management/presentation/widgets/room_requests_dialog.dart';
import 'package:ancyra_sailing/l10n/app_locale.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/l10n/locale_provider.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

part 'main_screen.g.dart';

// TabController provider'ı
@riverpod
class TabControllerState extends _$TabControllerState {
  @override
  TabController? build() {
    return null;
  }

  void setTabController(TabController? controller) {
    state = controller;
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    // Provider'dan temizle
    ref.read(tabControllerStateProvider.notifier).setTabController(null);
    _tabController.dispose();
    super.dispose();
  }

  String _getPageTitle(BuildContext context, int index) {
    switch (index) {
      case 0:
        return AppTranslations.t(context, 'tabInProgress');
      case 1:
        return AppTranslations.t(context, 'tabCompleted');
      case 2:
        return AppTranslations.t(context, 'tabCreateTask');
      default:
        return AppTranslations.t(context, 'mainScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    
    // TabController'ı provider'a kaydet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tabControllerStateProvider.notifier).setTabController(_tabController);
    });
    
    final roomId = ref.watch(selectedRoomProvider);
    final roomAsync = roomId != null ? ref.watch(loadRoomProvider(roomId)) : null;

    final currentUserAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Appstyles.white,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Appstyles.lightBlue,
            shape: BoxShape.circle,
            boxShadow: Appstyles.softShadow,
          ),
          child: IconButton(
            icon: const Icon(Icons.person),
            color: Appstyles.primaryBlue,
            onPressed: () => context.push('/account'),
            tooltip: AppTranslations.t(context, 'myAccount'),
          ),
        ),
        title: Text(
          _getPageTitle(context, currentIndex),
          style: Appstyles.headingTextStyle.copyWith(
            color: Appstyles.primaryBlue,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: Appstyles.primaryBlue),
        actions: [
          // Oda Seçimi
          roomAsync?.when(
            data: (room) {
              // Bekleyen istek sayısını kontrol et (sadece oda sahibi için)
              final isOwner = room != null && room.ownerId == ref.read(currentUserProvider).value?.uid;
              final pendingRequestsAsync = isOwner && roomId != null
                  ? ref.watch(pendingRoomRequestsCountProvider(roomId!))
                  : null;

              return PopupMenuButton<String>(
                tooltip: AppTranslations.t(context, 'roomInfo'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Appstyles.lightBlue,
                      shape: BoxShape.circle,
                      boxShadow: Appstyles.softShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: pendingRequestsAsync?.when(
                            data: (count) => count > 0
                                ? Badge(
                                    label: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Appstyles.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: Appstyles.primaryBlue,
                                      size: 24,
                                    ),
                                  )
                                : const Icon(
                                    Icons.info_outline,
                                    color: Appstyles.primaryBlue,
                                    size: 24,
                                  ),
                            loading: () => const Icon(
                              Icons.info_outline,
                              color: Appstyles.primaryBlue,
                              size: 24,
                            ),
                            error: (_, __) => const Icon(
                              Icons.info_outline,
                              color: Appstyles.primaryBlue,
                              size: 24,
                            ),
                          ) ??
                          const Icon(
                            Icons.info_outline,
                            color: Appstyles.primaryBlue,
                            size: 24,
                          ),
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'exit') {
                    // Odadan çık
                    ref.read(selectedRoomProvider.notifier).clear();
                    context.go('/roomSelection');
                  } else if (value == 'info' && room != null) {
                    // Oda bilgileri
                    _showRoomInfo(context, room);
                  } else if (value == 'requests' && room != null) {
                    // İstekler
                    _showRoomRequests(context, roomId!);
                  } else if (value == 'manage' && room != null) {
                    // Oda yönetimi (izinler)
                    _showRoomManagement(context, roomId!, room);
                  }
                },
                itemBuilder: (context) {
                  final pendingCountAsync = roomId != null && room != null && room.ownerId == ref.read(currentUserProvider).value?.uid
                      ? ref.watch(pendingRoomRequestsCountProvider(roomId!))
                      : null;
                  
                  return [
                    PopupMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Appstyles.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslations.t(context, 'roomInfo'),
                            style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'exit',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, color: Appstyles.primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            AppTranslations.t(context, 'changeRoom'),
                            style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
                          ),
                        ],
                      ),
                    ),
                    if (room != null && room.ownerId == ref.read(currentUserProvider).value?.uid)
                      PopupMenuItem(
                        value: 'requests',
                        child: pendingCountAsync?.when(
                              data: (count) => Row(
                                    children: [
                                      count > 0
                                          ? Badge(
                                              label: Text(
                                                '$count',
                                                style: Appstyles.normalTextStyle.copyWith(
                                                  color: Appstyles.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              child: Icon(Icons.notifications, color: Appstyles.primaryBlue),
                                            )
                                          : Icon(Icons.notifications, color: Appstyles.primaryBlue),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppTranslations.t(context, 'roomRequests'),
                                        style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
                                      ),
                                    ],
                                  ),
                              loading: () => Row(
                                    children: [
                                      Icon(Icons.notifications, color: Appstyles.primaryBlue),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppTranslations.t(context, 'roomRequests'),
                                        style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
                                      ),
                                    ],
                                  ),
                              error: (_, __) => Row(
                                    children: [
                                      Icon(Icons.notifications, color: Appstyles.primaryBlue),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppTranslations.t(context, 'roomRequests'),
                                        style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
                                      ),
                                    ],
                                  ),
                            ) ??
                                Row(
                                  children: [
                                    Icon(Icons.notifications, color: Appstyles.primaryBlue),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppTranslations.t(context, 'roomRequests'),
                                      style: Appstyles.normalTextStyle.copyWith(color: Appstyles.textDark),
                                    ),
                                  ],
                                ),
                      ),
                    if (room != null)
                      PopupMenuItem(
                        value: 'manage',
                        child: Row(
                          children: [
                            const Icon(Icons.settings),
                            const SizedBox(width: 8),
                            Text(AppTranslations.t(context, 'roomManage')),
                          ],
                        ),
                      ),
                  ];
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.error),
              onPressed: () => context.go('/roomSelection'),
            ),
          ) ?? Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Appstyles.lightBlue,
              shape: BoxShape.circle,
              boxShadow: Appstyles.softShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              color: Appstyles.primaryBlue,
              tooltip: AppTranslations.t(context, 'roomSelectTooltip'),
              onPressed: () => context.go('/roomSelection'),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: Appstyles.lightOceanGradient,
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            IncompleteTasksScreen(),
            CompletedTasksScreen(),
            AddTasksScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Appstyles.white,
          boxShadow: Appstyles.mediumShadow,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (value) {
            setState(() {
              currentIndex = value;
            });
            _tabController.animateTo(value);
          },
          iconSize: 24.0,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Appstyles.primaryBlue,
          unselectedItemColor: Appstyles.textLight,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          backgroundColor: Appstyles.white,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.warning_amber_outlined),
              label: AppTranslations.t(context, 'tabInProgress'),
              activeIcon: const Icon(Icons.warning_amber),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.check_circle_outline),
              label: AppTranslations.t(context, 'tabCompleted'),
              activeIcon: const Icon(Icons.check_circle),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline),
              label: AppTranslations.t(context, 'tabAdd'),
              activeIcon: const Icon(Icons.add_circle),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoomManagement(BuildContext context, String roomId, Room room) {
    showDialog(
      context: context,
      builder: (ctx) => RoomManagementDialog(roomId: roomId, room: room),
    );
  }

  void _showRoomRequests(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (ctx) => RoomRequestsDialog(roomId: roomId),
    );
  }

  void _showRoomInfo(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.meeting_room, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppTranslations.t(context, 'roomInfo'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(AppTranslations.t(context, 'roomNameLabel'), room.name),
            const SizedBox(height: 12),
            _buildInfoRow(AppTranslations.t(context, 'roomCodeLabel'), room.code, isCode: true),
            const SizedBox(height: 12),
            _buildInfoRow(AppTranslations.t(context, 'memberCount'), '${room.memberIds.length}'),
            const SizedBox(height: 12),
            _buildInfoRow(AppTranslations.t(context, 'createdAt'), _formatDate(room.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.t(context, 'close')),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCode = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Appstyles.subtitleTextStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCode ? Colors.blue[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCode ? Colors.blue[300]! : Colors.grey[300]!,
            ),
          ),
          child: SelectableText(
            value,
            style: Appstyles.normalTextStyle.copyWith(
              fontWeight: isCode ? FontWeight.bold : FontWeight.normal,
              color: isCode ? Appstyles.primaryBlue : Appstyles.textDark,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAccountDialog(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.read(currentUserProvider);
    
    currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppTranslations.t(context, 'userNotFound'))),
          );
          return;
        }
        
        showDialog(
          context: context,
          builder: (ctx) => Consumer(
            builder: (context, ref, _) {
              final displayNameAsync = ref.watch(loadUserDisplayNameProvider(currentUser.uid));
              
              return AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppTranslations.t(context, 'accountInfo'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                content: displayNameAsync.when(
                  data: (displayName) {
                    final currentLocale = ref.watch(localeProvider);
                    final currentAppLocale = AppLocale.fromLocale(currentLocale);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(Icons.account_circle, color: Colors.blueGrey, size: 80),
                        ),
                        const SizedBox(height: 16),
                        _buildEditableNameRow(context, ref, currentUser.uid, displayName ?? ''),
                        const SizedBox(height: 16),
                        _buildInfoRow(AppTranslations.t(context, 'email'), currentUser.email ?? AppTranslations.t(context, 'emailNone')),
                        const SizedBox(height: 16),
                        // Dil seçenekleri
                        Text(
                          AppTranslations.t(context, 'language'),
                          style: Appstyles.subtitleTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButton<AppLocale>(
                            value: currentAppLocale,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            items: AppLocale.values
                                .map((appLocale) => DropdownMenuItem<AppLocale>(
                                      value: appLocale,
                                      child: Text(appLocale.displayName),
                                    ))
                                .toList(),
                            onChanged: (appLocale) async {
                              if (appLocale != null) {
                                await ref
                                    .read(localeProvider.notifier)
                                    .setLocale(appLocale);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Text(AppTranslations.t(context, 'errorOccurred')),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(AppTranslations.t(context, 'close')),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final userId = currentUser.uid;
                      
                      // Oda seçimini temizle
                      ref.read(selectedRoomProvider.notifier).clear();
                      
                      // Tüm provider'ları invalidate et
                      ref.invalidate(selectedRoomProvider);
                      if (userId != null) {
                        ref.invalidate(loadUserRoomsProvider(userId));
                        ref.invalidate(loadUserRoomRequestsProvider(userId));
                      }
                      
                      // Çıkış yap
                      await ref.read(authRepositoryProvider).signOut();
                      
                      // Biraz bekle ki Firebase state güncellensin
                      await Future.delayed(const Duration(milliseconds: 500));
                      
                      // Sign in ekranına yönlendir
                      if (context.mounted) {
                        context.go('/signIn');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppTranslations.t(context, 'signOut')),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () {
        showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          ),
        );
      },
      error: (_, __) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.t(context, 'errorOccurred'))),
        );
      },
    );
  }

  Widget _buildEditableNameRow(BuildContext context, WidgetRef ref, String userId, String currentName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.t(context, 'name'),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  currentName.isEmpty ? AppTranslations.t(context, 'nameNotSet') : currentName,
                  style: TextStyle(
                    fontSize: 14,
                    color: currentName.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editDisplayName(context, ref, userId, currentName),
            ),
          ],
        ),
      ],
    );
  }

  void _editDisplayName(BuildContext context, WidgetRef ref, String userId, String currentName) async {
    final controller = TextEditingController(text: currentName);
    
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.t(context, 'editName')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppTranslations.t(context, 'enterName'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx, controller.text.trim());
            },
            child: Text(AppTranslations.t(context, 'save')),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        await ref.read(roomRepositoryProvider).updateUserDisplayName(userId, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslations.t(context, 'nameUpdated')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppTranslations.t(context, 'errorPrefix')}: $e')),
          );
        }
      }
    }
  }

}
