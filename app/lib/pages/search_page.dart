import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:librairian/models/item.dart';
import 'package:librairian/services/matches.dart';
import 'package:librairian/widgets/chat_prompt.dart';
import 'package:librairian/widgets/chat_response.dart';

class MatchRequest {
  final String prompt;
  final double matchThreshold;
  final int maxResults;
  late Future<List<MatchItem>> matches;

  MatchRequest(this.prompt, this.matchThreshold, this.maxResults) {
    matches = getMatches(prompt, matchThreshold / 100, maxResults);
  }

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
  double matchThreshold = 50;
  int maxResults = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceBright,
            borderRadius: MediaQuery.of(context).size.width < 600
                ? const BorderRadius.all(Radius.circular(0))
                : const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0))),
        child: Column(children: [
          Padding(
              padding:
                  const EdgeInsets.only(left: 16, top: 1, bottom: 1, right: 16),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Text("Match threshold:"),
                      Slider(
                          min: 0,
                          max: 100,
                          divisions: 10,
                          value: matchThreshold,
                          onChanged: (value) {
                            setState(() {
                              matchThreshold = value;
                            });
                          }),
                      const SizedBox(width: 20),
                      const Text("Maximum results:"),
                      const SizedBox(width: 10),
                      SegmentedButton(
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
                          selected: <int>{
                            maxResults
                          },
                          onSelectionChanged: (value) {
                            setState(() {
                              maxResults = value.first;
                            });
                          })
                    ]),
                    IconButton(
                        tooltip: "Clear chat",
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            matchRequests = [];
                          });
                        }),
                  ])),
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
                                                    alignment:
                                                        Alignment.centerLeft,
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
                                                    matches:
                                                        snapshot.data ?? []));
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                                snapshot.error.toString());
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
                                  hintText:
                                      "Describe the item you are looking for",
                                  suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: IconButton(
                                        icon: const Icon(Icons.send, size: 20),
                                        onPressed: () {
                                          setState(() {
                                            matchRequests.insert(
                                                0,
                                                MatchRequest(
                                                  controller.text,
                                                  matchThreshold,
                                                  maxResults,
                                                ));
                                            controller.clear();
                                          });
                                          scrollController.animateTo(
                                            0,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ))),
                              keyboardType: TextInputType.text,
                              maxLength: 1000,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              maxLines: 5,
                              minLines: 1,
                              onFieldSubmitted: (_) async {
                                focusNode.requestFocus();
                                if (controller.text != "") {
                                  setState(() {
                                    matchRequests.insert(
                                        0,
                                        MatchRequest(controller.text,
                                            matchThreshold, maxResults));
                                    controller.clear();
                                  });
                                  scrollController.animateTo(
                                    0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }))
                    ])
                  ])))
        ]));
  }
}
