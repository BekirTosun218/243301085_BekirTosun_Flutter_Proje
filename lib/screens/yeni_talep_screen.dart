import 'package:flutter/material.dart';
import '../services/talep_service.dart';

class YeniTalepScreen extends StatefulWidget {
  const YeniTalepScreen({super.key});

  @override
  State<YeniTalepScreen> createState() => _YeniTalepScreenState();
}

class _YeniTalepScreenState extends State<YeniTalepScreen> {
  final _hastaController = TextEditingController();
  final _tcController = TextEditingController();
  final _kaynakController = TextEditingController();
  final _hedefController = TextEditingController();
  final _aciklamaController = TextEditingController();
  String _aciliyet = 'normal';
  bool _loading = false;

  Future<void> _kaydet() async {
    if (_hastaController.text.trim().isEmpty ||
        _kaynakController.text.trim().isEmpty ||
        _hedefController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen yıldızlı (*) alanları doldurun')),
      );
      return;
    }

    setState(() => _loading = true);

    final error = await TalepService.create(
      hastaAdSoyad: _hastaController.text.trim(),
      hastaTc: _tcController.text.trim().isEmpty
          ? null
          : _tcController.text.trim(),
      kaynakKurum: _kaynakController.text.trim(),
      hedefKurum: _hedefController.text.trim(),
      aciliyet: _aciliyet,
      aciklama: _aciklamaController.text.trim().isEmpty
          ? null
          : _aciklamaController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pop(context, true); // true = liste yenilensin sinyali
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Talep Oluştur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _hastaController,
              decoration: const InputDecoration(
                labelText: 'Hasta Ad Soyad *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tcController,
              decoration: const InputDecoration(
                labelText: 'Hasta TC (opsiyonel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              maxLength: 11,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kaynakController,
              decoration: const InputDecoration(
                labelText: 'Kaynak Kurum *',
                hintText: 'Örn: Konya Şehir Hastanesi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_hospital),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hedefController,
              decoration: const InputDecoration(
                labelText: 'Hedef Kurum *',
                hintText: 'Örn: Selçuk Tıp Fakültesi Hastanesi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aciliyet Durumu *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'normal',
                    label: Text('Normal'),
                    icon: Icon(Icons.info)),
                ButtonSegment(
                    value: 'acil',
                    label: Text('Acil'),
                    icon: Icon(Icons.warning)),
                ButtonSegment(
                    value: 'kritik',
                    label: Text('Kritik'),
                    icon: Icon(Icons.priority_high)),
              ],
              selected: {_aciliyet},
              onSelectionChanged: (val) =>
                  setState(() => _aciliyet = val.first),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aciklamaController,
              decoration: const InputDecoration(
                labelText: 'Açıklama (opsiyonel)',
                hintText: 'Hasta durumu, özel notlar...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _kaydet,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: const Text('Talebi Kaydet',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}