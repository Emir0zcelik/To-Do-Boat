import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ancyra_sailing/l10n/app_locale.dart';
import 'package:ancyra_sailing/l10n/locale_provider.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

class AuthAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final currentAppLocale = AppLocale.fromLocale(currentLocale);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Ancyra Sailing',
        style: Appstyles.titleTextStyle.copyWith(
          color: Appstyles.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: DropdownButton<AppLocale>(
            value: currentAppLocale,
            underline: const SizedBox.shrink(),
            dropdownColor: Appstyles.white,
            items: AppLocale.values
                .map((appLocale) => DropdownMenuItem<AppLocale>(
                      value: appLocale,
                      child: Text(
                        appLocale.displayName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Appstyles.primaryBlue,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (appLocale) async {
              if (appLocale != null) {
                await ref.read(localeProvider.notifier).setLocale(appLocale);
              }
            },
          ),
        ),
      ],
    );
  }
}
