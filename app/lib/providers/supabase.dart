import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase.g.dart';

@riverpod
User? supabaseUser(SupabaseUserRef ref) {
  return Supabase.instance.client.auth.currentUser;
}
