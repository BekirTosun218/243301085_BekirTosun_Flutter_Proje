import '../main.dart';

class LogService {
  static Future<void> log(String islem, {String? detay}) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      await supabase.from('loglar').insert({
        'kullanici_id': userId,
        'islem': islem,
        'detay': detay,
      });
    } catch (e) {
      print('Log hatası: $e');
    }
  }
}