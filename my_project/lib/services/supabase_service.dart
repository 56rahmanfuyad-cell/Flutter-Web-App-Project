import 'package:supabase_flutter/supabase_flutter.dart';

// CampusShare project connection details.
// This publishable key is safe for a client app; never put a secret key here.
const String supabaseUrl = 'https://yftkbrstwxfwlgpvwfnf.supabase.co';
const String supabasePublishableKey =
    'sb_publishable_DUjv5S18MmKZ_IR2lnZFOg_PJV_pnCF';

/// A small helper for the Supabase client and authentication actions.
class SupabaseService {
  static bool get isConfigured {
    return supabaseUrl.startsWith('https://') &&
        supabasePublishableKey.startsWith('sb_publishable_');
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  static String? get currentUserEmail => currentUser?.email;

  static String get currentUserName {
    final metadata = currentUser?.userMetadata;
    final fullName = metadata?['name'] ?? metadata?['full_name'];
    if (fullName is String && fullName.isNotEmpty) return fullName;
    return currentUserEmail?.split('@').first ?? 'Student';
  }

  static bool get isAuthenticated => client.auth.currentSession != null;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String university,
    required String department,
    required String phoneNumber,
  }) async {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'university': university,
        'department': department,
        'phone_number': phoneNumber,
      },
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  // Save one profile row for this Auth user. Upsert avoids duplicate rows.
  static Future<void> saveProfile({
    required String userId,
    required String name,
    required String? university,
    required String? department,
    required String? phoneNumber,
  }) async {
    await client.from('profiles').upsert(
      {
        'id': userId,
        'name': name,
        'university': university,
        'department': department,
        'phone_number': phoneNumber,
      },
      onConflict: 'id',
    );
  }

  // Read only the profile row whose id matches the signed-in user's UUID.
  static Future<Map<String, dynamic>?> fetchCurrentProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    return client
        .from('profiles')
        .select('id, name, university, department, phone_number')
        .eq('id', userId)
        .maybeSingle();
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
