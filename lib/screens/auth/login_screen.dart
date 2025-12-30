import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../home/home_feed.dart';

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

    final emailRegex = RegExp(r'^.{1,}@gmail\.com$');
    final phoneRegex = RegExp(r'^(\+251[79]\d{8}|[07]\d{9})$');

    if (emailRegex.hasMatch(text) || phoneRegex.hasMatch(text)) {
      return null;
    }
    return 'Use Gmail (user@gmail.com) or ET phone (+2519/7 or 09/07)';
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Minimum 8 characters';

    final strongPass =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

    if (!strongPass.hasMatch(text)) {
      return 'Must include letter, digit & special char';
    }
    return null;
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN BODY: "${response.body}"');
      print('LOGIN HEADERS: ${response.headers}');

      dynamic data;
      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          print('JSON decode error: $e');
          data = null;
        }
      }

      if (response.statusCode == 200 && data != null && data['user'] != null) {
        final user = data['user'];
        final int userId = user['userId'];
        final String fullName = user['fullName'];
        final String email = user['email'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeFeed(
              userId: userId,
              fullName: fullName,
              email: email,
            ),
          ),
        );
      } else {
        final errorMessage = (data != null && data['error'] is String)
            ? data['error']
            : 'Login failed (status ${response.statusCode})';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
