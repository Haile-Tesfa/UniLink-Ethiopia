import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/images/auth/login_bg.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/auth/logo.jpg', height: 80),
                const SizedBox(height: 40),
                _inputField("Email or phone"),
                const SizedBox(height: 15),
                _inputField("Password", isPass: true),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(250, 50)),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                  child: const Text("Login", style: TextStyle(color: Colors.white)),
                ),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: const Text("Sign Up", style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String hint, {bool isPass = false}) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: TextField(obscureText: isPass, decoration: InputDecoration(hintText: hint, border: InputBorder.none)),
    );
  }
}