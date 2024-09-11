import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/item.dart' as provider;
import 'package:librairian/providers/matches.dart';
import 'package:librairian/widgets/chat_prompt.dart';
import 'package:librairian/widgets/chat_response.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/item_edit_form.dart';
import 'package:librairian/widgets/search_config.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<MatchRequest> matchRequests = [];
  final FocusNode focusNode = FocusNode();
  double matchThreshold = 0.5;
  int maxResults = 10;
  String searchMode = "by description";
  Item? selectedItem;
  bool textFieldEnabled = true;

  void update(Item item) async {
    ref.read(matchesProvider.notifier).update(item);
  }

  void search() async {
    setState(() {
      textFieldEnabled = false;
    });
    if (controller.text != "") {
      if (searchMode == "by description") {
        ref
            .read(matchesProvider.notifier)
            .matchesByDescription(controller.text, matchThreshold, maxResults)
            .then((value) {
          setState(() {
            textFieldEnabled = true;
            if (MediaQuery.of(context).size.width > 600) {
              focusNode.requestFocus();
            }
          });
        });
        controller.clear();
      } else {
        ref
            .read(matchesProvider.notifier)
            .matchesByName(controller.text, maxResults)
            .then((value) {
          setState(() {
            textFieldEnabled = true;
            if (MediaQuery.of(context).size.width > 600) {
              focusNode.requestFocus();
            }
          });
        });
      }
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        appBar: const CustomAppBar(
          title: Text("Search Items"),
        ),
        body: content(context),
      );
    }
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 600
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: content(context));
  }

  Widget content(BuildContext context) {
    var matches = ref.watch(matchesProvider);
    return Column(children: [
      Container(
          color: MediaQuery.of(context).size.width < 600
              ? Theme.of(context).colorScheme.surfaceDim
              : null,
          child: SearchConfig(
            onClearChat: () {
              setState(() {
                matchRequests = [];
              });
            },
            onChangeMaxResults: (value) {
              setState(() {
                maxResults = value;
              });
            },
            onChangeMatchThreshold: (value) {
              setState(() {
                matchThreshold = value;
              });
            },
            onChangeSearchMode: (value) {
              setState(() {
                searchMode = value;
              });
            },
          )),
      Divider(
        color: Theme.of(context).colorScheme.surfaceDim,
        height: 0,
      ),
      Expanded(
          child: Column(children: [
        Expanded(
            child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: ListView(
                                  shrinkWrap: true,
                                  reverse: true,
                                  children: [
                                    for (var i = 0;
                                        i < matches.length;
                                        i++) ...[
                                      if (matches[i].matches is AsyncError)
                                        const Text("Error"),
                                      if (matches[i].matches is AsyncLoading)
                                        const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(),
                                                ))),
                                      if (matches[i].matches is AsyncData)
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: ChatResponse(
                                                selected: selectedItem,
                                                onSelect: (item) {
                                                  setState(() {
                                                    selectedItem = item;
                                                  });
                                                },
                                                matches:
                                                    matches[i].matches.value ??
                                                        [])),
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: ChatPrompt(
                                              prompt: matches[i].prompt)),
                                      if (i < matches.length - 1) ...[
                                        const Divider(),
                                      ]
                                    ]
                                  ]))),
                      if (selectedItem != null) ...[
                        VerticalDivider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          width: 1,
                        ),
                        Expanded(
                            child: ItemEditForm(
                                item: selectedItem!,
                                onSave: (item) {
                                  ref
                                      .read(provider.itemProvider.notifier)
                                      .save(item);
                                  update(item);
                                  setState(() {
                                    selectedItem = null;
                                  });
                                },
                                onCancel: () {
                                  setState(() {
                                    selectedItem = null;
                                  });
                                }))
                      ]
                    ]))),
        Divider(color: Theme.of(context).colorScheme.surfaceDim, height: 0),
        Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Expanded(
                  child: TextFormField(
                      focusNode: focusNode,
                      scrollController: scrollController,
                      controller: controller,
                      decoration: InputDecoration(
                          hintText: searchMode == "by description"
                              ? "Describe the item you are looking for"
                              : "Name of the item you are looking for",
                          suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: IconButton(
                                icon: const Icon(Icons.send, size: 20),
                                onPressed: !textFieldEnabled
                                    ? null
                                    : () async {
                                        search();
                                      },
                              ))),
                      keyboardType: TextInputType.text,
                      maxLines: 5,
                      minLines: 1,
                      onFieldSubmitted: !textFieldEnabled
                          ? null
                          : (_) async {
                              focusNode.requestFocus();
                              search();
                            }))
            ]))
      ]))
    ]);
  }
}
