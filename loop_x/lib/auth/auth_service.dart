import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(email: email, password: password);
      if (res.user == null) throw Exception('Signup failed. No user returned.');
      return res;
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (res.user == null) throw Exception('Login failed. No user returned.');
      return res;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
