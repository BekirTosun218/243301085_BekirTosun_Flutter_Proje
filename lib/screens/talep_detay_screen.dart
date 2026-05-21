import 'package:flutter/material.dart';
import '../main.dart';
import '../models/profile.dart';
import '../models/talep.dart';
import '../services/profile_service.dart';
import '../services/talep_service.dart';

class TalepDetayScreen extends StatefulWidget {
  final Talep talep;

  const TalepDetayScreen({super.key, required this.talep});

  @override
  State<TalepDetayScreen> createState() => _TalepDetayScreenState();
}

class _TalepDetayScreenState extends State<TalepDetayScreen> {
  late Talep _talep;
  Profile? _olusturanProfile;
  Profile? _currentProfile;
  bool _loading = true;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _talep = widget.talep;
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final olusturan = await ProfileService.getById(_talep.olusturanId);
    final current = await ProfileService.getCurrent();
    if (!mounted) return;
    setState(() {
      _olusturanProfile = olusturan;
      _currentProfile = current;
      _loading = false;
    });
  }

  Future<void> _durumDegistir(String yeniDurum) async {
    setState(() => _updating = true);
    final error = await TalepService.updateDurum(
      talepId: _talep.id,
      yeniDurum: yeniDurum,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _updating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    final guncel = await TalepService.getById(_talep.id);
    if (!mounted) return;

    setState(() {
      if (guncel != null) _talep = guncel;
      _updating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Durum güncellendi: ${_durumMetni(yeniDurum)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _aciliyetRengi(String a) {
    switch (a) {
      case 'kritik':
        return Colors.red;
      case 'acil':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _durumRengi(String d) {
    switch (d) {
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

  String _durumMetni(String d) {
    switch (d) {
      case 'beklemede':
        return 'Beklemede';
      case 'gorevlendirildi':
        return 'Görevlendirildi';
      case 'tamamlandi':
        return 'Tamamlandı';
      case 'iptal':
        return 'İptal';
      default:
        return d;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Talep Detayı')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isDispatcher = _currentProfile?.isDispatcher ?? false;
    final isOwner = _talep.olusturanId == supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Talep Detayı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _durumRengi(_talep.durum).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _durumRengi(_talep.durum)),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag, color: _durumRengi(_talep.durum)),
                  const SizedBox(width: 12),
                  Text(
                    'Durum: ${_durumMetni(_talep.durum)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _durumRengi(_talep.durum),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _aciliyetRengi(_talep.aciliyet),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _talep.aciliyet.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _baslik('Hasta Bilgileri'),
            _bilgiSatiri(Icons.person, 'Ad Soyad', _talep.hastaAdSoyad),
            if (_talep.hastaTc != null && _talep.hastaTc!.isNotEmpty)
              _bilgiSatiri(Icons.credit_card, 'TC', _talep.hastaTc!),
            const SizedBox(height: 16),
            _baslik('Nakil Bilgileri'),
            _bilgiSatiri(
                Icons.local_hospital, 'Kaynak Kurum', _talep.kaynakKurum),
            _bilgiSatiri(
                Icons.location_on, 'Hedef Kurum', _talep.hedefKurum),
            if (_talep.aciklama != null && _talep.aciklama!.isNotEmpty)
              _bilgiSatiri(Icons.notes, 'Açıklama', _talep.aciklama!),
            const SizedBox(height: 16),
            _baslik('Talep Eden'),
            _bilgiSatiri(Icons.account_circle, 'Kullanıcı',
                _olusturanProfile?.adSoyad ?? 'Bilinmiyor'),
            if (_olusturanProfile?.kurum != null)
              _bilgiSatiri(Icons.business, 'Kurum', _olusturanProfile!.kurum!),
            _bilgiSatiri(Icons.calendar_today, 'Oluşturma Tarihi',
                _formatDate(_talep.createdAt)),
            const SizedBox(height: 24),
            if (isDispatcher && _talep.durum == 'beklemede') ...[
              _baslik('Görevlendirme'),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _updating
                      ? null
                      : () => _durumDegistir('gorevlendirildi'),
                  icon: const Icon(Icons.assignment_ind),
                  label: const Text('Görevlendir',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            if (isDispatcher && _talep.durum == 'gorevlendirildi') ...[
              _baslik('İşlem'),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      _updating ? null : () => _durumDegistir('tamamlandi'),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Tamamlandı Olarak İşaretle',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            if ((isDispatcher || isOwner) &&
                (_talep.durum == 'beklemede' ||
                    _talep.durum == 'gorevlendirildi')) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed:
                      _updating ? null : () => _durumDegistir('iptal'),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Talebi İptal Et'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
            if (_updating) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _baslik(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _bilgiSatiri(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}