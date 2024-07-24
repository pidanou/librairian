import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'matches.g.dart';

@riverpod
class Matches extends _$Matches {
  @override
  Future<List<MatchItem>> build(
      String input, double threshold, int maxResults) async {
    String url;
    url =
        'http://localhost:8080/api/v1/item/matches?search=$input&threshold=$threshold&max_results=$maxResults';
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
}
