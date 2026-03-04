import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.signInWithIdentifier(
        identifier: _idCtrl.text,
        password: _pwCtrl.text,
      );
      // AuthGate zaten StartScreen'e götürecek
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    // Basit mesaj yeterli
    if (raw.contains('user-not-found')) return 'Kullanıcı bulunamadı.';
    if (raw.contains('wrong-password') || raw.contains('invalid-credential')) {
      return 'Şifre yanlış.';
    }
    if (raw.contains('invalid-email')) return 'Email formatı hatalı.';
    return 'Giriş başarısız: $raw';
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 16),
            const Text('TripDNA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),

            TextField(
              controller: _idCtrl,
              decoration: const InputDecoration(
                labelText: 'Email or username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pwCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}