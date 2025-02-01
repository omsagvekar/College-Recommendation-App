import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url =
      'https://whvvjpfxuciljriqnpxz.supabase.co'; // Replace with your Supabase URL
  static const String key =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndodnZqcGZ4dWNpbGpyaXFucHh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgyNjAzOTEsImV4cCI6MjA1MzgzNjM5MX0.6_Upw_kKVF3kplHsFeYJ6r294yz-YYCP8gyRyinqKCU'; // Replace with your Supabase public API key

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        anonKey: key,
      );
      print('Supabase initialized successfully!');
    } catch (e) {
      print('Error initializing Supabase: $e');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}
