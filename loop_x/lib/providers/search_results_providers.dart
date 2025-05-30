import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userSearchServiceProvider = Provider<UserSearchService>((ref) {
  final client = Supabase.instance.client;
  return UserSearchService(client);
});

// Search results provider that depends on a query
final userSearchResultsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  
  final service = ref.read(userSearchServiceProvider);
  return service.searchUsers(query);
});

class UserSearchService{
  final SupabaseClient _client;
  UserSearchService(this._client);
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) {
      return [];
    }
    try {
      final response = await _client
          .from('profiles')
          .select('id, username, avatar_url')
          .ilike('username', '%$query%')
          .limit(20);
          
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching users: $e');
      throw Exception('Failed to search users');
    }
  }
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, username, avatar_url, bio')
          .eq('id', userId)
          .single();
          
      return response;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  /// Save a search to the user's search history
  Future<void> saveSearchQuery(String query) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null || query.isEmpty) {
      return;
    }
    
    try {
      await _client.from('search_history').insert({
        'user_id': userId,
        'query': query,
        'searched_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving search: $e');
    }
  }
  }

