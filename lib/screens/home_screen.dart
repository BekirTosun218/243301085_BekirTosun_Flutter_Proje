import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sağlık Nakil Sistemi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Giriş başarılı!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Hoş geldin: ${user?.email ?? "kullanıcı"}'),
            const SizedBox(height: 24),
            const Text(
              'Talepler ekranı yarın eklenecek',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}