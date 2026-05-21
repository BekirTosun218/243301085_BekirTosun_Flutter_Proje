class Profile {
  final String id;
  final String adSoyad;
  final String kullaniciTipi;
  final String? kurum;
  final String? telefon;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.adSoyad,
    required this.kullaniciTipi,
    this.kurum,
    this.telefon,
    required this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      adSoyad: map['ad_soyad'] as String,
      kullaniciTipi: map['kullanici_tipi'] as String,
      kurum: map['kurum'] as String?,
      telefon: map['telefon'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isDispatcher => kullaniciTipi == 'dispatcher';
  bool get isTalepEden => kullaniciTipi == 'talep_eden';
  String get rolMetni => isDispatcher ? 'Görevlendiren' : 'Talep Eden';
}