import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  Future<void> _register() async {
    try {
      await _auth.signUp(_emailCtrl.text, _passCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Check your email for confirmation")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(controller: _emailCtrl, label: 'Email'),
            CustomTextField(controller: _passCtrl, label: 'Password', obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
