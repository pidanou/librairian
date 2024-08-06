import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/shared_preferences.dart';
import 'package:librairian/routes.dart';
import 'package:librairian/theme/chip.dart';
import 'package:librairian/theme/input_decoration.dart';
import 'package:librairian/theme/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

Future main() async {
  usePathUrlStrategy();
  await Supabase.initialize(
    url: const String.fromEnvironment("SUPABASE_URL"),
    anonKey: const String.fromEnvironment("SUPABASE_ANON_KEY"),
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('fr'),
        ],
        debugShowCheckedModeBanner: false,
        title: "Librairian",
        routerConfig: goRouter,
        theme: ThemeData(
          useMaterial3: true,
          chipTheme: CustomChipDecorationThemeData.all(),
          inputDecorationTheme: CustomInputDecorationTheme.all(),
          colorScheme: MaterialTheme.lightScheme(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          chipTheme: CustomChipDecorationThemeData.all(),
          inputDecorationTheme: CustomInputDecorationTheme.all(),
          colorScheme: MaterialTheme.darkScheme(),
        ));
  }
}
