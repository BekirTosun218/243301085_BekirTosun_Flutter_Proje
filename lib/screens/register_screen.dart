import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adSoyadController = TextEditingController();
  final _kurumController = TextEditingController();
  final _telefonController = TextEditingController();
  String _kullaniciTipi = 'talep_eden';
  bool _loading = false;

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _adSoyadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen tüm zorunlu (*) alanları doldurun')),
      );
      return;
    }

    setState(() => _loading = true);

    final error = await AuthService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      adSoyad: _adSoyadController.text.trim(),
      kullaniciTipi: _kullaniciTipi,
      kurum: _kurumController.text.trim().isEmpty
          ? null
          : _kurumController.text.trim(),
      telefon: _telefonController.text.trim().isEmpty
          ? null
          : _telefonController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _adSoyadController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Şifre * (en az 6 karakter)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kurumController,
              decoration: const InputDecoration(
                labelText: 'Kurum (Hastane/Birim)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefonController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Kullanıcı Tipi *',
                  style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'talep_eden', label: Text('Talep Eden')),
                ButtonSegment(
                    value: 'dispatcher', label: Text('Görevlendiren')),
              ],
              selected: {_kullaniciTipi},
              onSelectionChanged: (val) =>
                  setState(() => _kullaniciTipi = val.first),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Kayıt Ol',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}