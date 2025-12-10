import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // REGISTER
  Future<String?> register({
    required String email,
    required String password,
}) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        await _client.from('profiles').insert({
          'id': userId,
          'email': email,
          'role': 'user',
        });

        return null;
      } else {
        return "Register gagal";
      }
    } catch (e) {
      return e.toString();
    }
  }

  // LOGIN
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        final profile = await _client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        return profile;
      }

      return null;
    } catch (e) {
      throw Exception(e);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}