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
                  redirectUrl:
                      kIsWeb ? null : 'io.librairian.app://login-callback/',
                  socialButtonVariant: SocialButtonVariant.icon,
                  socialProviders: const [
                    OAuthProvider.google,
                    // OAuthProvider.facebook
                  ],
                  colored: true,
                  onSuccess: (Session response) {
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
