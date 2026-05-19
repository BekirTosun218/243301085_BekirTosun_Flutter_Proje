class Talep {
  final String id;
  final String olusturanId;
  final String hastaAdSoyad;
  final String? hastaTc;
  final String kaynakKurum;
  final String hedefKurum;
  final String aciliyet;
  final String? aciklama;
  final String durum;
  final String? atananId;
  final DateTime createdAt;

  Talep({
    required this.id,
    required this.olusturanId,
    required this.hastaAdSoyad,
    this.hastaTc,
    required this.kaynakKurum,
    required this.hedefKurum,
    required this.aciliyet,
    this.aciklama,
    required this.durum,
    this.atananId,
    required this.createdAt,
  });

  factory Talep.fromMap(Map<String, dynamic> map) {
    return Talep(
      id: map['id'] as String,
      olusturanId: map['olusturan_id'] as String,
      hastaAdSoyad: map['hasta_ad_soyad'] as String,
      hastaTc: map['hasta_tc'] as String?,
      kaynakKurum: map['kaynak_kurum'] as String,
      hedefKurum: map['hedef_kurum'] as String,
      aciliyet: map['aciliyet'] as String,
      aciklama: map['aciklama'] as String?,
      durum: map['durum'] as String,
      atananId: map['atanan_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}