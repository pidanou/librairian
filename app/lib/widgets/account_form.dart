import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/providers/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountForm extends ConsumerStatefulWidget {
  const AccountForm({super.key});

  @override
  ConsumerState createState() => AccountFormState();
}

class AccountFormState extends ConsumerState<AccountForm> {
  bool editing = false;
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.email),
            subtitle:
                Text(ref.watch(supabaseUserProvider)?.email ?? "No email"),
          ),
          ListTile(
              title: Text(AppLocalizations.of(context)!.password),
              subtitle: TextFormField(
                obscureText: true,
                enabled: editing,
                controller: passwordController,
                onChanged: (value) {
                  _formKey.currentState!.validate();
                },
                validator: (value) {
                  if (!editing) return null;
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Passwork must be at least 6 characters';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    hintText: "***********", isDense: true),
              )),
          if (editing)
            ListTile(
                title: Text(AppLocalizations.of(context)!.confirmPassword),
                subtitle: TextFormField(
                    enabled: editing,
                    controller: passwordConfirmController,
                    onChanged: (value) {
                      _formKey.currentState!.validate();
                    },
                    validator: (value) {
                      if (!editing) return null;
                      if (value != passwordController.text ||
                          value == null ||
                          value.isEmpty) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "***********",
                    ))),
          ListTile(
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (editing)
              TextButton(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () => setState(() {
                  passwordController.clear();
                  passwordConfirmController.clear();
                  editing = false;
                  _formKey.currentState!.validate();
                }),
              ),
            FilledButton(
              child: Text(editing ? "Save" : "Edit"),
              onPressed: () async {
                if (!editing) {
                  setState(() {
                    editing = !editing;
                  });
                  return;
                }
                if (editing) {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(
                        password: passwordController.text,
                      ),
                    );
                    passwordController.clear();
                    passwordConfirmController.clear();
                    setState(() {
                      editing = !editing;
                    });
                  }
                }
              },
            )
          ]))
        ]));
  }
}
