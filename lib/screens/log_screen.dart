import 'package:flutter/material.dart';
import '../services/log_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<Map<String, dynamic>> _loglar = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loglar = await LogService.getMyLogs(limit: 30);
    if (!mounted) return;
    setState(() {
      _loglar = loglar;
      _loading = false;
    });
  }

  IconData _islemIkonu(String islem) {
    switch (islem) {
      case 'giris':
        return Icons.login;
      case 'cikis':
        return Icons.logout;
      case 'kayit':
        return Icons.person_add;
      case 'talep_olusturuldu':
        return Icons.add_circle;
      case 'talep_durum_degisti':
        return Icons.update;
      default:
        return Icons.info;
    }
  }

  Color _islemRengi(String islem) {
    switch (islem) {
      case 'giris':
        return Colors.green;
      case 'cikis':
        return Colors.orange;
      case 'kayit':
        return Colors.teal;
      case 'talep_olusturuldu':
        return Colors.blue;
      case 'talep_durum_degisti':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _islemMetni(String islem) {
    switch (islem) {
      case 'giris':
        return 'Giriş Yapıldı';
      case 'cikis':
        return 'Çıkış Yapıldı';
      case 'kayit':
        return 'Hesap Oluşturuldu';
      case 'talep_olusturuldu':
        return 'Yeni Talep Oluşturuldu';
      case 'talep_durum_degisti':
        return 'Talep Durumu Güncellendi';
      default:
        return islem;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşlem Geçmişi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loglar.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Henüz işlem kaydı yok',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _loglar.length,
                  itemBuilder: (context, index) {
                    final log = _loglar[index];
                    final islem = log['islem'] as String? ?? '';
                    final detay = log['detay'] as String?;
                    final createdAt = log['created_at'] as String? ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            _islemRengi(islem).withValues(alpha: 0.15),
                        child: Icon(
                          _islemIkonu(islem),
                          color: _islemRengi(islem),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _islemMetni(islem),
                        style:
                            const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (detay != null && detay.isNotEmpty)
                            Text(detay,
                                style: const TextStyle(fontSize: 12)),
                          Text(
                            _formatDate(createdAt),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}