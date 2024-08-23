import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Center(
        child: SizedBox(
            width: 500,
            child: Column(
              children: [
                Text('Welcome to Librarian',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 32),
                SupaEmailAuth(
                  onSignInComplete: (response) {
                    GoRouter.of(context).go('/search');
                  },
                  onSignUpComplete: (response) {
                    GoRouter.of(context).go('/search');
                  },
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
                  redirectUrl:
                      kIsWeb ? null : 'io.librairian.app://login-callback/',
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
