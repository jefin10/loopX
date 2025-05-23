import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  final _confirmPassCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();

  final _auth = AuthService();
  final supabase = Supabase.instance.client;
  Future<void> _register() async {

    if(_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty || _usernameCtrl.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    } 
    if(_passCtrl.text != _confirmPassCtrl.text){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    try {
      final res = await _auth.signUp(_emailCtrl.text, _passCtrl.text);
      if(res.user != null){
        await supabase.from('profiles').insert({
          'id':res.user!.id,
          'username': _usernameCtrl.text, 
          'email': _emailCtrl.text,
          'bio': '',
          'avatar_url': '',
        });
      }
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
            CustomTextField(controller: _usernameCtrl, label: 'Username'),
            CustomTextField(controller: _passCtrl, label: 'Password', obscureText: true),
            CustomTextField(controller: _confirmPassCtrl, label: 'Confirm Password', obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
