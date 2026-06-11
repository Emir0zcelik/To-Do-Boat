import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tekne_demirbas/features/authentication/data/auth_repository.dart';
import 'package:tekne_demirbas/features/room_management/data/room_repository.dart';
import 'package:tekne_demirbas/features/room_management/presentation/providers/selected_room_provider.dart';
import 'package:tekne_demirbas/l10n/app_locale.dart';
import 'package:tekne_demirbas/l10n/app_translations.dart';
import 'package:tekne_demirbas/l10n/locale_provider.dart';
import 'package:tekne_demirbas/utils/appstyles.dart';
import 'package:tekne_demirbas/utils/size_config.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return Center(
              child: Text(AppTranslations.t(context, 'userNotFound')));
        }

        return _buildAccountContent(context, ref, currentUser);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          Center(child: Text(AppTranslations.t(context, 'errorOccurred'))),
    );
  }

  Widget _buildAccountContent(
      BuildContext context, WidgetRef ref, currentUser) {
    final currentLocale = ref.watch(localeProvider);
    final currentAppLocale = AppLocale.fromLocale(currentLocale);

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTranslations.t(context, 'accountInfo'),
              style: Appstyles.titleTextStyle.copyWith(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            const Icon(Icons.account_circle, color: Colors.blueGrey, size: 80),
            Text(currentUser.email!),
            SizedBox(height: SizeConfig.getProportionateHeight(20)),
            // Dil seçenekleri (dropdown)
            Text(
              AppTranslations.t(context, 'language'),
              style: Appstyles.normalTextStyle.copyWith(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            SizedBox(height: SizeConfig.getProportionateHeight(8)),
            SizedBox(
              width: SizeConfig.screenWidth * 0.75,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
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
            ),
            SizedBox(height: SizeConfig.getProportionateHeight(24)),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      AppTranslations.t(context, 'signOutConfirm'),
                      style: Appstyles.normalTextStyle,
                    ),
                    icon: const Icon(Icons.logout, color: Colors.red, size: 60),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(
                            AppTranslations.t(context, 'no'),
                            style: Appstyles.normalTextStyle),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          context.pop();
                          final userId = currentUser.uid;

                          ref.read(selectedRoomProvider.notifier).clear();
                          ref.invalidate(selectedRoomProvider);
                          if (userId != null) {
                            ref.invalidate(loadUserRoomsProvider(userId));
                            ref.invalidate(
                                loadUserRoomRequestsProvider(userId));
                          }

                          await ref.read(authRepositoryProvider).signOut();
                          await Future.delayed(
                              const Duration(milliseconds: 500));

                          if (context.mounted) {
                            context.go('/signIn');
                          }
                        },
                        child: Text(
                            AppTranslations.t(context, 'yes'),
                            style: Appstyles.normalTextStyle),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: SizeConfig.getProportionateHeight(50),
                width: SizeConfig.screenWidth * 0.80,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppTranslations.t(context, 'signOut'),
                  style: Appstyles.normalTextStyle.copyWith(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
