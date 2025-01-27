import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:librairian/constants/supabase_locale.dart';
import 'package:librairian/providers/supabase.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Center(
        child: SizedBox(
            width: 500,
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.welcome,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 32),
                SupaEmailAuth(
                  localization: createSupabaseLocalization(context),
                  onSignInComplete: (response) {
                    ref.invalidate(supabaseUserProvider);
                    GoRouter.of(context).go('/search');
                  },
                  onSignUpComplete: (response) {
                    ref.invalidate(supabaseUserProvider);
                    GoRouter.of(context).go('/search');
                  },
                  resetPasswordRedirectTo: kIsWeb
                      ? "http://localhost:3000/settings"
                      : "io.librairian.app://callback/settings/account",
                ),
                const Divider(),
                SupaSocialsAuth(
                  nativeGoogleAuthConfig: const NativeGoogleAuthConfig(
                      iosClientId:
                          "740244662736-6f5aa0sku5p283d8i7vj89tccunkntfd.apps.googleusercontent.com",
                      webClientId:
                          "740244662736-3pfti4ji50uhbchp7btj6st5210upceb.apps.googleusercontent.com"),
                  enableNativeAppleAuth: true,
                  showSuccessSnackBar: false,
                  redirectUrl: kIsWeb ? null : 'io.librairian.app://callback/',
                  socialButtonVariant: SocialButtonVariant.icon,
                  socialProviders: const [
                    OAuthProvider.google,
                    // OAuthProvider.facebook
                  ],
                  colored: true,
                  onSuccess: (Session response) {
                    Supabase.instance.client.auth.currentSession;
                    GoRouter.of(context).go('/search');
                  },
                  onError: (error) {
                    print(error);
                    // do something, for example: navigate("wait_for_email");
                  },
                ),
              ],
            )),
      )
    ]));
  }
}
