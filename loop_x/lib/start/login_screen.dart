import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_service.dart';
import 'register_screen.dart';
import '../widgets/custom_text_field.dart';
import 'package:another_flushbar/flushbar.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: "jefinfrancis10@gmail.com");
  final _passCtrl = TextEditingController(text: "jefin@123");
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      final res = await _auth.signIn(_emailCtrl.text, _passCtrl.text);
      if (res.user!=null){
        context.go('/');
      }
    } catch (e) {
      Flushbar(
        title: 'Error',
        message: 'Invalid credentials',
        duration: Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
        icon: Icon(Icons.error, color: Colors.white),
      )..show(context);

    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 40,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/x.png',
                height: 300,
              ),
              CustomTextField(controller: _emailCtrl, label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              CustomTextField(
                controller: _passCtrl,
                label: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.purple,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('No account? Register'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
