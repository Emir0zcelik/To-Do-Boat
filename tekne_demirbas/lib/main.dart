import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ancyra_sailing/core/notifications/notification_service.dart';
import 'package:ancyra_sailing/firebase_options.dart';
import 'package:ancyra_sailing/l10n/locale_provider.dart';
import 'package:ancyra_sailing/routes/routes.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';
import 'package:ancyra_sailing/utils/size_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.initialize();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      routerConfig: ref.watch(goRouterProvider),
      title: 'Ancyra Sailing',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('ru'),
      ],
      builder: (context, child) {
        SizeConfig.init(context);
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            appBarTheme: base.appBarTheme.copyWith(
              backgroundColor: Appstyles.primaryBlue,
              foregroundColor: Appstyles.white,
              centerTitle: true,
              toolbarHeight: SizeConfig.toolbarHeight,
              titleTextStyle: Appstyles.headingTextStyle.copyWith(
                color: Appstyles.white,
                fontSize: SizeConfig.sp(20),
              ),
              iconTheme: IconThemeData(
                color: Appstyles.white,
                size: SizeConfig.iconMd,
              ),
              actionsIconTheme: IconThemeData(
                color: Appstyles.white,
                size: SizeConfig.iconMd,
              ),
            ),
            bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
              backgroundColor: Appstyles.white,
              selectedItemColor: Appstyles.primaryBlue,
              unselectedItemColor: Appstyles.textLight,
              selectedIconTheme: IconThemeData(size: SizeConfig.sp(26)),
              unselectedIconTheme: IconThemeData(size: SizeConfig.sp(26)),
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: SizeConfig.sp(12),
                height: 1.1,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: SizeConfig.sp(12),
                height: 1.1,
              ),
            ),
            iconTheme: base.iconTheme.copyWith(size: SizeConfig.iconMd),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(64, SizeConfig.buttonHeight * 0.85),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sp(20),
                  vertical: SizeConfig.sp(14),
                ),
                textStyle: Appstyles.normalTextStyle.copyWith(
                  fontSize: SizeConfig.sp(16),
                  fontWeight: FontWeight.w600,
                  color: Appstyles.white,
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: Size(64, SizeConfig.buttonHeight * 0.85),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.sp(20),
                  vertical: SizeConfig.sp(14),
                ),
                textStyle: Appstyles.normalTextStyle.copyWith(
                  fontSize: SizeConfig.sp(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: Appstyles.normalTextStyle.copyWith(
                  fontSize: SizeConfig.sp(15),
                ),
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Appstyles.primaryBlue),
        scaffoldBackgroundColor: Appstyles.lightGray,
        useMaterial3: true,
      ),
    );
  }
}
