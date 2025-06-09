import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:supabase_flutter/supabase_flutter.dart";


final curentUserIdProvider = Provider<String?>((ref){
  final user = Supabase.instance.client.auth.currentUser;
  return user?.id;
});
final usernameForIdProvider = FutureProvider.family<String?, String?>((ref, userId) async {
  try {
    if (userId == null) return null;
    final response = await Supabase.instance.client
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .single();
    return response['username'] as String?;
  } catch (e) {
    return null;
  }
});

