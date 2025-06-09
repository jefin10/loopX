import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

final currentUserIdProvider = Provider<String?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser?.id;
});

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



final chatMessagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) {
  final supabase = ref.watch(supabaseProvider);
  
  return supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('chat_room_id', chatId)
    .order('created_at')
    .map((event) => List<Map<String, dynamic>>.from(event));
});


