import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'log_service.dart';

class AuthService {
  static Future<String?> signUp({
    required String email,
    required String password,
    required String adSoyad,
    required String kullaniciTipi,
    String? kurum,
    String? telefon,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user == null) return 'Kullanıcı oluşturulamadı';

      await supabase.from('profiles').insert({
        'id': user.id,
        'ad_soyad': adSoyad,
        'kullanici_tipi': kullaniciTipi,
        'kurum': kurum,
        'telefon': telefon,
      });

      await LogService.log('kayit', detay: email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Beklenmeyen hata: $e';
    }
  }

  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await LogService.log('giris', detay: email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Beklenmeyen hata: $e';
    }
  }

  static Future<void> signOut() async {
    await LogService.log('cikis');
    await supabase.auth.signOut();
  }
}