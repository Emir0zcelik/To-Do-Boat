import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ancyra_sailing/features/authentication/data/auth_repository.dart';
import 'package:ancyra_sailing/features/room_management/data/room_repository.dart';
import 'package:ancyra_sailing/features/room_management/presentation/providers/selected_room_provider.dart';
import 'package:ancyra_sailing/l10n/app_locale.dart';
import 'package:ancyra_sailing/l10n/app_translations.dart';
import 'package:ancyra_sailing/l10n/locale_provider.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.t(context, 'myAccount')),
      ),
      body: SafeArea(
        child: currentUserAsync.when(
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
        ),
      ),
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
            SizedBox(height: SizeConfig.getProportionateHeight(16)),
            InkWell(
              onTap: () => _showDeleteAccountDialog(context, ref),
              child: Container(
                alignment: Alignment.center,
                height: SizeConfig.getProportionateHeight(50),
                width: SizeConfig.screenWidth * 0.80,
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppTranslations.t(context, 'deleteAccount'),
                  style: Appstyles.normalTextStyle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(height: SizeConfig.getProportionateHeight(24)),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    bool isDeleting = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded,
              color: Colors.red, size: 48),
          title: Text(
            AppTranslations.t(context, 'deleteAccount'),
            style: Appstyles.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppTranslations.t(context, 'deleteAccountConfirm')}\n\n'
                '${AppTranslations.t(context, 'deleteAccountWarning')}',
                style: Appstyles.normalTextStyle,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText:
                      AppTranslations.t(context, 'enterPasswordToDelete'),
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  isDeleting ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(AppTranslations.t(context, 'cancel'),
                  style: Appstyles.normalTextStyle),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      final password = passwordController.text;
                      if (password.isEmpty) return;

                      setDialogState(() {
                        isDeleting = true;
                        errorText = null;
                      });

                      try {
                        ref.read(selectedRoomProvider.notifier).clear();
                        await ref
                            .read(authRepositoryProvider)
                            .deleteAccount(password: password);

                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppTranslations.t(
                                  context, 'accountDeleted')),
                              backgroundColor: Colors.green.shade400,
                            ),
                          );
                          context.go('/signIn');
                        }
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() {
                          isDeleting = false;
                          errorText = (e.code == 'wrong-password' ||
                                  e.code == 'invalid-credential')
                              ? AppTranslations.t(context, 'wrongPassword')
                              : AppTranslations.t(
                                  context, 'deleteAccountError');
                        });
                      } catch (_) {
                        setDialogState(() {
                          isDeleting = false;
                          errorText =
                              AppTranslations.t(context, 'deleteAccountError');
                        });
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppTranslations.t(context, 'yesDelete')),
            ),
          ],
        ),
      ),
    );
  }
}
