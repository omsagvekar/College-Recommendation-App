import 'supabase.dart'; // update with actual path

Future<Map<String, String>> fetchUserData() async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user != null) {
    final response = await SupabaseConfig.client
        .from('users')
        .select('full_name, email')
        .eq('id', user.id)
        .single();

    return {
      'full_name': response['full_name'] ?? 'User Name',
      'email': response['email'] ?? 'user@example.com',
    };
  } else {
    return {
      'full_name': 'User Name',
      'email': 'user@example.com',
    };
  }
}
