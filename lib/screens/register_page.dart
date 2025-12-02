// lib/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(); // NEW
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final auth = authService.value;

      // 1. Create account
      await auth.createAccount(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // 2. SET DISPLAY NAME
      await auth.currentUser!.updateDisplayName(_nameCtrl.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created!')),
      );

      Navigator.of(context).pushReplacementNamed('/login');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('রেজিস্টার')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NAME FIELD (NEW)
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'আপনার নাম',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.trim().isEmpty ? 'নাম দিন' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'ইমেইল',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => v!.isEmpty ? 'ইমেইল দিন' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'পাসওয়ার্ড',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) => v!.length < 6 ? 'কমপক্ষে ৬ অক্ষর' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'পুনরায় পাসওয়ার্ড',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v != _passCtrl.text ? 'মিলছে না' : null,
              ),
              const SizedBox(height: 24),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('রেজিস্টার করুন'),
              ),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('অ্যাকাউন্ট আছে? লগইন করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
