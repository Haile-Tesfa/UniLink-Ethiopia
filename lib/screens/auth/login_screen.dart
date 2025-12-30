
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _validateEmailOrPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email or phone is required';

    // Email: at least 1 char before @gmail.com
    final emailRegex = RegExp(r'^.{1,}@gmail\.com$');

    // Phone: +2519xxxxxxxx OR +2517xxxxxxxx OR 09xxxxxxxx OR 07xxxxxxxx
    final phoneRegex = RegExp(r'^(\+251[79]\d{8}|[07]\d{9})$');

    if (emailRegex.hasMatch(text) || phoneRegex.hasMatch(text)) {
      return null; // valid
    }
    return 'Use Gmail (user@gmail.com) or ET phone (+2519/7 or 09/07)';
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Minimum 8 characters';

    // At least 1 letter, 1 digit, 1 special char
    final strongPass =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

    if (!strongPass.hasMatch(text)) {
      return 'Must include letter, digit & special char';
    }
    return null;
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _emailOrPhoneController.text.trim(); // email or phone
    final password = _passwordController.text;

    try {
      final response = await http.post(
        // Windows / Chrome → localhost; Android emulator → change to 10.0.2.2
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login success: user exists in SQL with same email/phone + password
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/auth/login_bg.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/auth/logo.jpg', height: 80),
                  const SizedBox(height: 40),

                  // Email or Phone
                  Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _emailOrPhoneController,
                      decoration: const InputDecoration(
                        hintText: 'Email or phone',
                        border: InputBorder.none,
                      ),
                      validator: _validateEmailOrPhone,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                      ),
                      validator: _validatePassword,
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(250, 50),
                    ),
                    onPressed: _onLogin,
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/signup'),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
