import '../main.dart';
import '../models/profile.dart';

class ProfileService {
  /// Şu anki kullanıcının profilini getir
  static Future<Profile?> getCurrent() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    return getById(userId);
  }

  /// ID'ye göre profil getir
  static Future<Profile?> getById(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromMap(response);
    } catch (e) {
      return null;
    }
  }
}