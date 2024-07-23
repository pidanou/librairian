import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';

class ChatResponse extends ConsumerStatefulWidget {
  const ChatResponse({super.key, required this.matches});

  final List<MatchItem> matches;

  @override
  ChatResponseState createState() => ChatResponseState();
}

class ChatResponseState extends ConsumerState<ChatResponse> {
  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) {
      return const Card(
          child: Padding(
              padding: EdgeInsets.all(10), child: Text('No match found')));
    }
    return Column(children: [
      for (var match in widget.matches)
        Card(
            child: ListTile(
                isThreeLine: true,
                dense: true,
                leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            value: match.descriptionSimilarity),
                      ),
                      const SizedBox(height: 3),
                      Text(
                          '${(match.descriptionSimilarity * 100).toStringAsFixed(2)}%')
                    ]),
                title: Text(match.item?.name ?? ''),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(match.item?.description?.data ?? 'No description'),
                      Column(children: [
                        for (var sl in match.item?.storageLocations ?? [])
                          Wrap(children: [
                            Text(sl.storage?.alias),
                            const Text(' - '),
                            Text(sl.location),
                          ]),
                      ])
                    ]),
                trailing: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Wrap(spacing: 5, children: [
                      for (var tag in match.item?.tags ?? [])
                        Chip(label: Text(tag))
                    ]))))
    ]);
  }
}
