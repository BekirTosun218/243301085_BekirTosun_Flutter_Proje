import 'package:flutter/material.dart';
import '../models/talep.dart';
import '../services/auth_service.dart';
import '../services/talep_service.dart';
import 'yeni_talep_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  List<Talep> _talepler = [];
  String _filter = 'tumu'; // 'tumu' veya 'benim'

  @override
  void initState() {
    super.initState();
    _loadTalepler();
  }

  Future<void> _loadTalepler() async {
    setState(() => _loading = true);
    try {
      final list = _filter == 'tumu'
          ? await TalepService.getAll()
          : await TalepService.getMyTalepler();
      if (!mounted) return;
      setState(() {
        _talepler = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Talepler yüklenemedi: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Color _aciliyetRengi(String aciliyet) {
    switch (aciliyet) {
      case 'kritik':
        return Colors.red;
      case 'acil':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _durumRengi(String durum) {
    switch (durum) {
      case 'gorevlendirildi':
        return Colors.blue;
      case 'tamamlandi':
        return Colors.green;
      case 'iptal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _durumMetni(String durum) {
    switch (durum) {
      case 'beklemede':
        return 'Beklemede';
      case 'gorevlendirildi':
        return 'Görevlendirildi';
      case 'tamamlandi':
        return 'Tamamlandı';
      case 'iptal':
        return 'İptal';
      default:
        return durum;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sağlık Nakil Talepleri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTalepler,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'tumu', label: Text('Tüm Talepler')),
                ButtonSegment(
                    value: 'benim', label: Text('Benim Taleplerim')),
              ],
              selected: {_filter},
              onSelectionChanged: (val) {
                setState(() => _filter = val.first);
                _loadTalepler();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _talepler.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Henüz talep yok',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '+ butonuna basarak yeni talep ekleyebilirsiniz',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTalepler,
                        child: ListView.builder(
                          itemCount: _talepler.length,
                          itemBuilder: (context, index) {
                            final t = _talepler[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      _aciliyetRengi(t.aciliyet),
                                  child: const Icon(Icons.local_hospital,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  t.hastaAdSoyad,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                        '${t.kaynakKurum} → ${t.hedefKurum}'),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _etiket(t.aciliyet.toUpperCase(),
                                            _aciliyetRengi(t.aciliyet)),
                                        const SizedBox(width: 8),
                                        _etiket(_durumMetni(t.durum),
                                            _durumRengi(t.durum)),
                                      ],
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Detay ekranı yakında eklenecek')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final eklendi = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const YeniTalepScreen()),
          );
          if (!mounted) return;
          if (eklendi == true) {
            _loadTalepler();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Talep başarıyla oluşturuldu')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Talep'),
      ),
    );
  }

  Widget _etiket(String text, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: renk,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}