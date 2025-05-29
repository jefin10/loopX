import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider for Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for auth state (more reliable than direct access)
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

// Safe current user ID provider
final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser?.id;
});

// Username provider with null check
final usernameProvider = FutureProvider.family<String?, String>((ref, userId) async {
  final supabase = ref.watch(supabaseProvider);
  
  try {
    final response = await supabase
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .single();
    
    return response['username'] as String;
  } catch (e) {
    return null;
  }
});


// Add this to your existing providers

// Messages provider
final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) {
  final supabase = ref.watch(supabaseProvider);
  
  return supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('chat_room_id', chatId)
    .order('created_at')
    .map((event) => List<Map<String, dynamic>>.from(event));
});


