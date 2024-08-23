import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'matches.g.dart';

@riverpod
Future<List<MatchItem>> matchesByDescription(MatchesByDescriptionRef ref,
    String input, double threshold, int maxResults) async {
  String url;
  url =
      '${const String.fromEnvironment('API_URL')}/api/v1/items/matches?search=$input&threshold=$threshold&max_results=$maxResults';
  final token = Supabase.instance.client.auth.currentSession?.accessToken;
  final headers = {"Authorization": "Bearer $token"};

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<MatchItem>((json) => MatchItem.fromJson(json)).toList();
    } else {
      print("Erreur HTTP getting all storages : ${response.statusCode}");
    }
  } catch (e) {
    print("Exception : $e");
    return [];
  }
  return [];
}

@riverpod
Future<List<MatchItem>> matchesByName(
    MatchesByNameRef ref, String input, int maxResults) async {
  String url;
  url =
      '${const String.fromEnvironment('API_URL')}/api/v1/items?name=$input&page=1&limit=$maxResults&order_by=name&order=asc';
  final token = Supabase.instance.client.auth.currentSession?.accessToken;
  final headers = {"Authorization": "Bearer $token"};

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body)["data"];
      var test = data
          .map<Item>((json) => Item.fromJson(json))
          .map((item) => MatchItem(item: item, descriptionSimilarity: 1))
          .toList();
      print(test);
      return test;
    } else {
      print("Erreur HTTP getting all storages : ${response.statusCode}");
    }
  } catch (e) {
    print("Exception : $e");
    return [];
  }
  return [];
}
