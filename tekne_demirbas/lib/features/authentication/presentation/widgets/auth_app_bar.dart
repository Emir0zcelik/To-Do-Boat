import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ancyra_sailing/l10n/app_locale.dart';
import 'package:ancyra_sailing/l10n/locale_provider.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

class AuthAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const AuthAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(SizeConfig.toolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final currentLocale = ref.watch(localeProvider);
    final currentAppLocale = AppLocale.fromLocale(currentLocale);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: SizeConfig.toolbarHeight,
      title: Text(
        'Ancyra Sailing',
        style: Appstyles.titleTextStyle.copyWith(
          color: Appstyles.primaryBlue,
          fontWeight: FontWeight.w600,
          fontSize: SizeConfig.sp(20),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: SizeConfig.sp(12)),
          child: DropdownButton<AppLocale>(
            value: currentAppLocale,
            underline: const SizedBox.shrink(),
            dropdownColor: Appstyles.white,
            style: TextStyle(
              fontSize: SizeConfig.sp(14),
              color: Appstyles.primaryBlue,
            ),
            items: AppLocale.values
                .map((appLocale) => DropdownMenuItem<AppLocale>(
                      value: appLocale,
                      child: Text(
                        appLocale.displayName,
                        style: TextStyle(
                          fontSize: SizeConfig.sp(14),
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
