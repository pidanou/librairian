import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/widgets/account_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => AccountPageState();
}

class AccountPageState extends ConsumerState<AccountPage> {
  bool editingName = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surfaceDim,
            title: Text(AppLocalizations.of(context)!.myAccount),
            centerTitle: true),
        body: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceBright,
                borderRadius: MediaQuery.of(context).size.width < 840
                    ? const BorderRadius.all(Radius.circular(0))
                    : const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0))),
            child: const AccountForm()));
  }
}
