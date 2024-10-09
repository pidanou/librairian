import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

SupaEmailAuthLocalization createSupabaseLocalization(BuildContext context) {
  return SupaEmailAuthLocalization(
    enterEmail: AppLocalizations.of(context)!.enterEmail,
    validEmailError: AppLocalizations.of(context)!.validEmailError,
    enterPassword: AppLocalizations.of(context)!.enterPassword,
    passwordLengthError: AppLocalizations.of(context)!.passwordLengthError,
    signIn: AppLocalizations.of(context)!.signIn,
    signUp: AppLocalizations.of(context)!.signUp,
    forgotPassword: AppLocalizations.of(context)!.forgotPassword,
    dontHaveAccount: AppLocalizations.of(context)!.dontHaveAccount,
    haveAccount: AppLocalizations.of(context)!.haveAccount,
    sendPasswordReset: AppLocalizations.of(context)!.sendPasswordReset,
    passwordResetSent: AppLocalizations.of(context)!.passwordResetSent,
    backToSignIn: AppLocalizations.of(context)!.backToSignIn,
    unexpectedError: AppLocalizations.of(context)!.unexpectedError,
  );
}
