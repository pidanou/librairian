import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/constants/keys.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/providers/matches.dart';
import 'package:librairian/widgets/chat_prompt.dart';
import 'package:librairian/widgets/chat_response.dart';
import 'package:librairian/widgets/custom_appbar.dart';
import 'package:librairian/widgets/search_config.dart';

class MatchRequest {
  final String prompt;
  final double matchThreshold;
  final int maxResults;
  final Future<List<MatchItem>> matches;

  MatchRequest(
      {required this.prompt,
      required this.matchThreshold,
      required this.maxResults,
      required this.matches});

  @override
  String toString() {
    return prompt;
  }
}

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

  void search() {
    if (controller.text != "") {
      if (searchMode == "by description") {
        setState(() {
          matchRequests.insert(
              0,
              MatchRequest(
                  prompt: controller.text,
                  matchThreshold: matchThreshold,
                  maxResults: maxResults,
                  matches: ref.read(matchesByDescriptionProvider(
                          controller.text, matchThreshold, maxResults)
                      .future)));
          controller.clear();
        });
      } else {
        setState(() {
          matchRequests.insert(
              0,
              MatchRequest(
                  prompt: controller.text,
                  matchThreshold: matchThreshold,
                  maxResults: maxResults,
                  matches: ref.read(
                      matchesByNameProvider(controller.text, maxResults)
                          .future)));
          controller.clear();
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
    return Column(children: [
      SearchConfig(
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
      ),
      Divider(
        color: Theme.of(context).colorScheme.surfaceDim,
        height: 0,
      ),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Expanded(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: ListView(
                            shrinkWrap: true,
                            reverse: true,
                            children: [
                              for (var i = 0;
                                  i < matchRequests.length;
                                  i++) ...[
                                FutureBuilder(
                                    future: matchRequests[i].matches,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator())));
                                      }
                                      if (snapshot.hasData) {
                                        return Align(
                                            alignment: Alignment.centerLeft,
                                            child: ChatResponse(
                                                matches: snapshot.data ?? []));
                                      }
                                      if (snapshot.hasError) {
                                        return Text(snapshot.error.toString());
                                      }
                                      return Container();
                                    }),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: ChatPrompt(
                                        prompt: matchRequests[i].prompt)),
                                if (i < matchRequests.length - 1) ...[
                                  const Divider(),
                                  const SizedBox(height: 10),
                                ],
                                const SizedBox(height: 10),
                              ]
                            ]))),
                const SizedBox(height: 20),
                Row(children: [
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
                                    onPressed: () async {
                                      search();
                                    },
                                  ))),
                          keyboardType: TextInputType.text,
                          maxLines: 5,
                          minLines: 1,
                          onFieldSubmitted: (_) async {
                            focusNode.requestFocus();
                            search();
                          }))
                ])
              ])))
    ]);
  }
}
