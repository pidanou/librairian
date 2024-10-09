import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/widgets/item_listtile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatResponse extends ConsumerStatefulWidget {
  const ChatResponse(
      {super.key, required this.matches, this.onSelect, this.selected});

  final List<MatchItem> matches;
  final Function(Item)? onSelect;
  final Item? selected;

  @override
  ChatResponseState createState() => ChatResponseState();
}

class ChatResponseState extends ConsumerState<ChatResponse> {
  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) {
      return Card(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(AppLocalizations.of(context)!.noResult)));
    }
    return Column(children: [
      for (var match in widget.matches)
        Card(
            child: ItemListTile(
          item: match.item ?? Item(),
          trailing:
              widget.selected?.id == match.item?.id && widget.selected != null
                  ? AvatarGlow(
                      glowRadiusFactor: 0.2,
                      glowCount: 1,
                      glowColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: Icon(Icons.info,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () {},
                      ))
                  : IconButton(
                      icon: Icon(Icons.info,
                          color: widget.selected?.id == match.item?.id &&
                                  widget.selected != null
                              ? Theme.of(context).colorScheme.primary
                              : null),
                      onPressed: () {
                        if (MediaQuery.of(context).size.width < 840) {
                          GoRouter.of(context).go(
                              "/search/detail/${match.item?.id}",
                              extra: match.item);
                        } else {
                          widget.onSelect?.call(match.item!);
                        }
                      },
                    ),
          leading:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(value: match.similarity),
            ),
            const SizedBox(height: 3),
            Text('${(match.similarity * 100).toStringAsFixed(2)}%')
          ]),
        ))
    ]);
  }
}
