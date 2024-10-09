import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/storage.dart';
import 'package:librairian/providers/storage.dart' as sp;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DialogAddStorage extends ConsumerStatefulWidget {
  const DialogAddStorage({super.key});

  @override
  DialogAddStorageState createState() => DialogAddStorageState();
}

class DialogAddStorageState extends ConsumerState<DialogAddStorage> {
  TextEditingController controller = TextEditingController();
  String type = "Device";

  Widget content(context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Storage Name',
        ),
        controller: controller,
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            Storage newStorage = Storage(
                alias: controller.text,
                userId: Supabase.instance.client.auth.currentUser!.id);
            ref
                .read(sp.storagesProvider.notifier)
                .add(newStorage)
                .then((value) {
              if (context.mounted) Navigator.pop(context);
            }).catchError((e) {
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.error)));
              }
            });
          },
          child: Text(AppLocalizations.of(context)!.add),
        )
      ],
      title: Text(AppLocalizations.of(context)!.add),
      content: content(context),
    );
  }
}
