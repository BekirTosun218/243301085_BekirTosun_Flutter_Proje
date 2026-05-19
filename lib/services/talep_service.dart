import '../main.dart';
import '../models/talep.dart';
import 'log_service.dart';

class TalepService {
  static Future<List<Talep>> getAll() async {
    final response = await supabase
        .from('talepler')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Talep.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Talep>> getMyTalepler() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await supabase
        .from('talepler')
        .select()
        .eq('olusturan_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((row) => Talep.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  static Future<String?> create({
    required String hastaAdSoyad,
    String? hastaTc,
    required String kaynakKurum,
    required String hedefKurum,
    required String aciliyet,
    String? aciklama,
  }) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return 'Kullanıcı oturumu bulunamadı';

      await supabase.from('talepler').insert({
        'olusturan_id': userId,
        'hasta_ad_soyad': hastaAdSoyad,
        'hasta_tc': hastaTc,
        'kaynak_kurum': kaynakKurum,
        'hedef_kurum': hedefKurum,
        'aciliyet': aciliyet,
        'aciklama': aciklama,
      });

      await LogService.log('talep_olusturuldu', detay: hastaAdSoyad);
      return null;
    } catch (e) {
      return 'Talep oluşturulamadı: $e';
    }
  }
}