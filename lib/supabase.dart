import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url =
      'Replace with your Supabase URL'; // Replace with your Supabase URL
  static const String key =
      'Replace with your Supabase public API key'; // Replace with your Supabase public API key

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
