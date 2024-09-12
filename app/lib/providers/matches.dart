import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'matches.g.dart';

class MatchRequest {
  final String prompt;
  AsyncValue<List<MatchItem>> matches;

  MatchRequest({required this.prompt, required this.matches});

  @override
  String toString() {
    return prompt;
  }
}

@riverpod
class Matches extends _$Matches {
  @override
  List<MatchRequest> build() {
    return [];
  }

  void update(Item item) async {
    List<MatchRequest> newState = state;
    for (var mr in newState) {
      var matches = mr.matches.value ?? [];
      for (var match in matches) {
        if (match.item?.id == item.id) {
          match.item = item;
        }
        mr.matches = AsyncValue.data(matches);
      }
    }
    state = newState;
  }

  Future<void> matchesByDescription(
      String input, double threshold, int maxResults) async {
    String url;
    url =
        '${const String.fromEnvironment('API_URL')}/api/v1/items/matches?search=$input&threshold=$threshold&max_results=$maxResults';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {"Authorization": "Bearer $token"};

    state = [
      MatchRequest(prompt: input, matches: const AsyncValue.loading()),
      ...state
    ];

    state = [
      MatchRequest(
          prompt: input,
          matches: await AsyncValue.guard(() async {
            var response = await http.get(Uri.parse(url), headers: headers);
            var data = jsonDecode(response.body);
            return data
                .map<MatchItem>((json) => MatchItem.fromJson(json))
                .toList();
          })),
      ...state.sublist(1)
    ];
  }

  Future<void> matchesByName(String input, int maxResults) async {
    String url;
    url =
        '${const String.fromEnvironment('API_URL')}/api/v1/items?name=$input&page=1&limit=$maxResults&order_by=name&order=asc';
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = {"Authorization": "Bearer $token"};
    state = [
      MatchRequest(prompt: input, matches: const AsyncValue.loading()),
      ...state
    ];

    state = [
      MatchRequest(
          prompt: input,
          matches: await AsyncValue.guard(() async {
            var response = await http.get(Uri.parse(url), headers: headers);
            var data = jsonDecode(response.body)["data"];
            List<MatchItem> test = (data as List<dynamic>)
                .map<Item>((json) => Item.fromJson(json))
                .map((item) => MatchItem(item: item, descriptionSimilarity: 1))
                .toList();
            return test;
          })),
      ...state.sublist(1)
    ];
  }
}
