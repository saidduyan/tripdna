import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  DateTime? _dob;
  bool _loading = false;
  String? _error;

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 90, 1, 1);
    final last = DateTime(now.year - 10, 12, 31); // 10 yaş altını engelle (istersen değiştir)

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 22, 1, 1),
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_dob == null) {
        throw Exception('Please select date of birth.');
      }
      await AuthService.register(
        email: _emailCtrl.text,
        password: _pwCtrl.text,
        firstName: _firstCtrl.text,
        lastName: _lastCtrl.text,
        username: _userCtrl.text,
        dateOfBirth: _dob!,
      );
      if (mounted) Navigator.pop(context); // login ekranına dön
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('username-taken')) return 'Bu kullanıcı adı alınmış.';
    if (raw.contains('email-already-in-use')) return 'Bu email zaten kayıtlı.';
    if (raw.contains('weak-password')) return 'Şifre çok zayıf.';
    if (raw.contains('invalid-email')) return 'Email formatı hatalı.';
    return 'Kayıt başarısız: $raw';
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dobText = _dob == null
        ? 'Select date of birth'
        : '${_dob!.day.toString().padLeft(2, '0')}/'
          '${_dob!.month.toString().padLeft(2, '0')}/'
          '${_dob!.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _firstCtrl,
              decoration: const InputDecoration(labelText: 'First name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastCtrl,
              decoration: const InputDecoration(labelText: 'Last name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: _loading ? null : _pickDob,
              child: Text(dobText),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _pwCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),

            const SizedBox(height: 12),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}