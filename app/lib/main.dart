import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/shared_preferences.dart';
import 'package:librairian/routes.dart';
import 'package:librairian/theme/input_decoration_theme.dart';
import 'package:librairian/theme/material_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
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
        debugShowCheckedModeBanner: false,
        title: "Librairian",
        routerConfig: goRouter,
        theme: ThemeData(
          useMaterial3: true,
          inputDecorationTheme: CustomInputDecorationTheme.all(),
          colorScheme: MaterialTheme.lightScheme(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          inputDecorationTheme: CustomInputDecorationTheme.all(),
          colorScheme: MaterialTheme.darkScheme(),
        ));
  }
}
