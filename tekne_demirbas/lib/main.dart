import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ancyra_sailing/core/notifications/notification_service.dart';
import 'package:ancyra_sailing/firebase_options.dart';
import 'package:ancyra_sailing/l10n/locale_provider.dart';
import 'package:ancyra_sailing/routes/routes.dart';
import 'package:ancyra_sailing/utils/appstyles.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Appstyles.primaryBlue),
        scaffoldBackgroundColor: Appstyles.lightGray,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: Appstyles.primaryBlue,
          foregroundColor: Appstyles.white,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          backgroundColor: Appstyles.primaryBlue,
          selectedItemColor: Appstyles.white,
          unselectedItemColor: Appstyles.lightBlue,
        ),
        useMaterial3: true,
      ),
    );
  }
}
