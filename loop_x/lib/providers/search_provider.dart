import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for auth state (more reliable than direct access)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser?.id;
});


final searchHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final currentUserId = supabase.auth.currentUser?.id;

  if (currentUserId == null) {
    return Stream.value([]);
  }

  return supabase
      .from('search_history')
      .stream(primaryKey: ['id'])
      .eq('user_id', currentUserId)
      .order('searched_at', ascending: false)
      .map((event) => List<Map<String, dynamic>>.from(event));
});
final searchHistoryControllerProvider = Provider((ref) {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser?.id;
  return _SearchHistoryController(client, userId);
});

class _SearchHistoryController {
  final SupabaseClient client;
  final String? userId;

  _SearchHistoryController(this.client, this.userId);

  Future<void> addSearch(String query) async {
    if (userId == null || query.isEmpty) return;
    await client.from('search_history').insert({
      'user_id': userId,
      'query': query,
      'searched_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteSearch(int id) async {
    if (userId == null) return;
    await client.from('search_history').delete().eq('id', id);
  }
}


