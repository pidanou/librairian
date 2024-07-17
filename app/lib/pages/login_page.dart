import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SupaEmailAuth(
        onSignInComplete: (response) {
          GoRouter.of(context).go('/');
        },
        onSignUpComplete: (response) {
          GoRouter.of(context).go('/');
        },
        metadataFields: [
          MetaDataField(
            prefixIcon: const Icon(Icons.person),
            label: 'Username',
            key: 'username',
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please enter something';
              }
              return null;
            },
          ),
        ],
      ),
    ));
  }
}
