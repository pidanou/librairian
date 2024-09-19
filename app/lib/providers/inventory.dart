import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:librairian/models/item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

part 'inventory.g.dart';

@riverpod
class InventoryPage extends _$InventoryPage {
  @override
  int build() {
    return 1;
  }

  void previous() {
    state = max(state - 1, 1);
  }

  void next() {
    state = state + 1;
  }
}

@riverpod
int inventoryLimit(InventoryLimitRef ref) {
  return 10;
}

@riverpod
class InventoryOrder extends _$InventoryOrder {
  @override
  String build() {
    return "";
  }

  void set(String value) {
    state = value;
  }
}

@riverpod
class InventoryAsc extends _$InventoryAsc {
  @override
  bool build() {
    return false;
  }

  void set(bool value) {
    state = value;
  }
}

@riverpod
Future<PaginatedItemsList?> inventory(InventoryRef ref) async {
  int page = ref.watch(inventoryPageProvider);
  int limit = ref.watch(inventoryLimitProvider);
  String orderBy = ref.watch(inventoryOrderProvider);
  bool asc = ref.watch(inventoryAscProvider);

  String url =
      '${const String.fromEnvironment('API_URL')}/api/v1/items?limit=$limit&page=$page&order_by=$orderBy&asc=$asc';
  final token = Supabase.instance.client.auth.currentSession?.accessToken;
  final headers = {"Authorization": "Bearer $token"};

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode < 300) {
      final dynamic data = jsonDecode(response.body);
      return PaginatedItemsList.fromJson(data);
    } else {
      print("Http error : ${response.body}");
    }
  } catch (e) {
    print("Exception : $e");
    return null;
  }
  return null;
}
