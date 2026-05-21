import 'package:flutter/material.dart';
import '../main.dart';
import '../models/profile.dart';
import '../models/talep.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/talep_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Profile? _profile;
  List<Talep> _talepler = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await ProfileService.getCurrent();
      final myTalepler = await TalepService.getMyTalepler();

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _talepler = myTalepler;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil bilgileri yüklenemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cikisYap() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = _profile;
    final user = supabase.auth.currentUser;

    if (p == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: const Center(child: Text('Profil yüklenemedi')),
      );
    }

    final toplam = _talepler.length;
    final beklemede =
        _talepler.where((t) => t.durum == 'beklemede').length;
    final gorevli =
        _talepler.where((t) => t.durum == 'gorevlendirildi').length;
    final tamamlandi =
        _talepler.where((t) => t.durum == 'tamamlandi').length;
    final iptal = _talepler.where((t) => t.durum == 'iptal').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.teal,
                    child: Text(
                      p.adSoyad.isNotEmpty
                          ? p.adSoyad.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.adSoyad,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.isDispatcher ? Colors.blue : Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p.rolMetni,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Kişisel Bilgiler',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _bilgiSatiri(Icons.email, 'E-posta', user?.email ?? '-'),
                  if (p.telefon != null && p.telefon!.isNotEmpty)
                    _bilgiSatiri(Icons.phone, 'Telefon', p.telefon!),
                  if (p.kurum != null && p.kurum!.isNotEmpty)
                    _bilgiSatiri(Icons.business, 'Kurum', p.kurum!),
                  _bilgiSatiri(Icons.calendar_today, 'Üyelik Tarihi',
                      _formatDate(p.createdAt)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Talep İstatistiklerim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _istatistik('Toplam', toplam, Colors.teal),
                        _istatistik('Beklemede', beklemede, Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _istatistik(
                            'Görevlendirildi', gorevli, Colors.blue),
                        _istatistik('Tamamlandı', tamamlandi, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _istatistik('İptal', iptal, Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _cikisYap,
                icon: const Icon(Icons.logout),
                label: const Text('Çıkış Yap',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _bilgiSatiri(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 16, color: Colors.black87)),
    );
  }

  Widget _istatistik(String label, int sayi, Color renk) {
    return Column(
      children: [
        Text(
          sayi.toString(),
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: renk),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}