import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/keys.dart';

class SearchConfig extends ConsumerStatefulWidget {
  final void Function(String) onChangeSearchMode;
  final void Function(double) onChangeMatchThreshold;
  final void Function(int) onChangeMaxResults;
  final VoidCallback onClearChat;

  const SearchConfig({
    super.key,
    required this.onChangeMatchThreshold,
    required this.onChangeMaxResults,
    required this.onClearChat,
    required this.onChangeSearchMode,
  });

  @override
  SearchConfigState createState() => SearchConfigState();
}

class SearchConfigState extends ConsumerState<SearchConfig> {
  String searchMode = "by description";
  double matchThreshold = 0.5;
  int maxResults = 10;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 840) {
      return ListTile(
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        MenuAnchor(
            key: searchFilterKey,
            menuChildren: [
              MenuItemButton(
                onPressed: () {
                  setState(() {
                    searchMode = "by description";
                  });
                  widget.onChangeSearchMode(searchMode);
                },
                child: const Text('by description'),
              ),
              MenuItemButton(
                onPressed: () {
                  setState(() {
                    searchMode = "by name";
                  });
                  widget.onChangeSearchMode(searchMode);
                },
                child: const Text('by name'),
              ),
            ],
            builder: (_, MenuController controller, Widget? child) {
              return ActionChip(
                  label: Text(searchMode),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  });
            }),
        const SizedBox(width: 5),
        MenuAnchor(
            menuChildren: [
              Slider(
                  min: 0,
                  max: 1,
                  divisions: 10,
                  value: matchThreshold,
                  onChanged: (value) {
                    setState(() {
                      matchThreshold = value;
                    });
                    widget.onChangeMatchThreshold(matchThreshold);
                  }),
            ],
            builder: (_, MenuController controller, Widget? child) {
              return ActionChip(
                  label: Text("${matchThreshold * 100}% similarity"),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  });
            }),
        const SizedBox(width: 5),
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: () {
                setState(() {
                  maxResults = 10;
                });
                widget.onChangeMaxResults(maxResults);
              },
              child: const Text('10'),
            ),
            MenuItemButton(
              onPressed: () {
                setState(() {
                  maxResults = 20;
                });
                widget.onChangeMaxResults(maxResults);
              },
              child: const Text('20'),
            ),
            MenuItemButton(
              onPressed: () {
                setState(() {
                  maxResults = 50;
                });
                widget.onChangeMaxResults(maxResults);
              },
              child: const Text('50'),
            ),
          ],
          builder: (_, MenuController controller, Widget? child) {
            return ActionChip(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              label: Text('$maxResults results'),
            );
          },
        ),
      ]));
    }
    return Padding(
        padding: const EdgeInsets.only(left: 16, top: 1, bottom: 1, right: 16),
        child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(children: [
                    Tooltip(
                        message: "Search mode",
                        child: SegmentedButton(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: "by description",
                                label: Text("by description"),
                              ),
                              ButtonSegment(
                                value: "by name",
                                label: Text("by item name"),
                              ),
                            ],
                            selected: <String>{searchMode},
                            onSelectionChanged: (value) {
                              setState(() {
                                searchMode = value.first;
                              });
                              widget.onChangeSearchMode(searchMode);
                            })),
                    Tooltip(
                        message: "Match threshold",
                        child: Slider(
                            min: 0,
                            max: 1,
                            divisions: 10,
                            value: matchThreshold,
                            onChanged: (value) {
                              setState(() {
                                matchThreshold = value;
                              });
                              widget.onChangeMatchThreshold(matchThreshold);
                            })),
                    Tooltip(
                        message: "Max results",
                        child: SegmentedButton(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(
                                value: 10,
                                label: Text("10"),
                              ),
                              ButtonSegment(
                                value: 20,
                                label: Text("20"),
                              ),
                              ButtonSegment(
                                value: 50,
                                label: Text("50"),
                              ),
                            ],
                            selected: <int>{maxResults},
                            onSelectionChanged: (value) {
                              setState(() {
                                maxResults = value.first;
                              });
                              widget.onChangeMaxResults(maxResults);
                            })),
                  ]),
                ))));
  }
}
