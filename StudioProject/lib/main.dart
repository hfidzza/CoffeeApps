import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/supabase_config.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: "https://mxnwdfpqyrnuulpibbsd.supabase.co",
    anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14bndkZnBxeXJudXVscGliYnNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0Nzc1MjUsImV4cCI6MjA4MDA1MzUyNX0.uhMpKl24ZPqd2t80FQuIzI8pKY88AzGc7OX---aB2CU",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const SplashScreen(), // START DARI SPLASH
    );
  }
}
