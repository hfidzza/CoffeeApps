import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://mxnwdfpqyrnuulpibbsd.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14bndkZnBxeXJudXVscGliYnNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0Nzc1MjUsImV4cCI6MjA4MDA1MzUyNX0.uhMpKl24ZPqd2t80FQuIzI8pKY88AzGc7OX---aB2CU';

  static final SupabaseClient client =
      SupabaseClient(supabaseUrl, anonKey);
}