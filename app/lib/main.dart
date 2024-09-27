import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/locale.dart';
import 'package:librairian/providers/shared_preferences.dart';
import 'package:librairian/providers/supabase.dart';
import 'package:librairian/routes.dart';
import 'package:librairian/theme/chip.dart';
import 'package:librairian/theme/input_decoration.dart';
import 'package:librairian/theme/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Locale appLocale = ref.watch(localeStateProvider);

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (!context.mounted) return;
      switch (event) {
        case AuthChangeEvent.initialSession:
        // handle initial session
        case AuthChangeEvent.signedIn:
        // handle signed in
        case AuthChangeEvent.signedOut:
        // handle signed out
        case AuthChangeEvent.passwordRecovery:
        // handle password recovery
        case AuthChangeEvent.tokenRefreshed:
        // handle token refreshed
        case AuthChangeEvent.userUpdated:
        // handle user updated
        case AuthChangeEvent.userDeleted:
        // handle user deleted
        case AuthChangeEvent.mfaChallengeVerified:
        // handle mfa challenge verified
      }
      ref.invalidate(supabaseUserProvider);
    });

    return AdaptiveTheme(
        light: ThemeData(
          useMaterial3: true,
          chipTheme: CustomChipDecorationThemeData.all(),
          inputDecorationTheme: CustomInputDecorationTheme.all(),
          colorScheme: MaterialTheme.lightScheme(),
        ),
        dark: ThemeData(
          useMaterial3: true,
          chipTheme: CustomChipDecorationThemeData.all(),
          inputDecorationTheme: CustomInputDecorationTheme.all(),
          colorScheme: MaterialTheme.darkScheme(),
        ),
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp.router(
            locale: appLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
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
            theme: theme,
            darkTheme: darkTheme));
  }
}
