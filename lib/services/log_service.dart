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

  static Future<List<Map<String, dynamic>>> getMyLogs(
      {int limit = 30}) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await supabase
          .from('loglar')
          .select()
          .eq('kullanici_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}