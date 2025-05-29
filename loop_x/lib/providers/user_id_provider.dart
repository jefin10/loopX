import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:supabase_flutter/supabase_flutter.dart";


final curentUserIdProvider = Provider<String?>((ref){
  final user = Supabase.instance.client.auth.currentUser;
  return user?.id;
});

