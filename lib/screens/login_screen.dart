import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  // ── Yeni eklenenler ────────────────────────────────────────
  List<String> _recentUsernames = [];
  List<String> _suggestions = [];
  // ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadRecentUsernames();
    _identifierController.addListener(_onIdentifierChanged);
  }

  @override
  void dispose() {
    _identifierController.removeListener(_onIdentifierChanged);
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Yeni metodlar ──────────────────────────────────────────

  Future<void> _loadRecentUsernames() async {
    final recent = await AuthService().getRecentUsernames();
    if (mounted) setState(() => _recentUsernames = recent);
  }

  void _onIdentifierChanged() {
    final input = _identifierController.text.toLowerCase();
    if (input.isEmpty) {
      setState(() => _suggestions = _recentUsernames);
      return;
    }
    setState(() {
      _suggestions = _recentUsernames
          .where((u) => u.toLowerCase().startsWith(input))
          .toList();
    });
  }

  void _selectSuggestion(String username) {
    _identifierController.text = username;
    _identifierController.selection = TextSelection.fromPosition(
      TextPosition(offset: username.length),
    );
    setState(() => _suggestions = []);
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text(
              'Enter your email address and we\'ll send you a reset link.'),
          const SizedBox(height: 16),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty) return;
              try {
                await AuthService().resetPassword(emailCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset link sent! Check your email 📧'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email not found. Check and try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService().login(
        identifier: _identifierController.text,
        password: _passwordController.text,
      );
      await AuthService().saveRecentUsername(_identifierController.text.trim());
    } catch (e) {
      setState(() => _error = _friendlyError(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found') ||
        raw.contains('wrong-password') ||
        raw.contains('invalid-credential')) {
      return 'Incorrect email/username or password.';
    }
    if (raw.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Firebase not configured. Check google-services.json and enable Email/Password auth in Console.';
    }
    if (raw.contains('network')) return 'Network error. Check your connection.';
    return 'Login failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.travel_explore,
                            size: 56, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text('TripDNA',
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Sign in to continue',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.outline)),
                        const SizedBox(height: 28),

                        // ── Email/Username + suggestions ──
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _identifierController,
                              decoration: const InputDecoration(
                                labelText: 'Email or Username',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              onTap: () {
                                if (_identifierController.text.isEmpty) {
                                  setState(
                                      () => _suggestions = _recentUsernames);
                                }
                              },
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            if (_suggestions.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(12)),
                                  border: Border.all(
                                      color: theme.colorScheme.outlineVariant),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Column(
                                  children: _suggestions.map((username) {
                                    return ListTile(
                                      dense: true,
                                      leading: Icon(Icons.history,
                                          size: 18,
                                          color: theme.colorScheme.outline),
                                      title: Text(username,
                                          style: theme.textTheme.bodyMedium),
                                      trailing: Icon(Icons.north_west,
                                          size: 16,
                                          color: theme.colorScheme.outline),
                                      onTap: () => _selectSuggestion(username),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                        // ─────────────────────────────────

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),

                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_error!,
                                style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer)),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // ── Forgot password ───────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        // ─────────────────────────────────

                        const SizedBox(height: 8),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _loading ? null : _login,
                            style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Sign In',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          child: const Text("Don't have an account? Register"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
