import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ancyra_sailing/firebase_options.dart';
import 'package:ancyra_sailing/l10n/locale_provider.dart';
import 'package:ancyra_sailing/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        appBarTheme: AppBarTheme().copyWith(
          backgroundColor: Colors.cyanAccent,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
          backgroundColor: Colors.cyanAccent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
        ),
        useMaterial3: true,
      ),
    );
  }
}
