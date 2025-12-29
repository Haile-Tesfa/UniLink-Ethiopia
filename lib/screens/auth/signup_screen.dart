import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/auth/wisdom.jpg"),
            fit: BoxFit.cover,
            opacity: 0.1, // Soft overlay for readability
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 60.0),
          child: Column(
            children: [
              // Authentication Illustration from your assets
              Image.asset(
                "assets/images/auth/auth_illustration.jpg",
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                "Join UniLink",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 30),

              // Input Fields
              _buildTextField("Full Name", Icons.person_outline),
              const SizedBox(height: 15),
              _buildTextField("University Email", Icons.email_outlined),
              const SizedBox(height: 15),
              _buildTextField("Password", Icons.lock_outline, isObscure: true),
              const SizedBox(height: 15),
              _buildTextField("Confirm Password", Icons.lock_reset,
                  isObscure: true),

              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                  child: const Text("Sign Up",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),

              const SizedBox(height: 20),
              const Text("— Or sign up with —",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // Social Media Buttons
              Row(
                children: [
                  Expanded(
                    child: _socialButton("Google",
                        "assets/images/auth/logo.jpg"), // Reusing logo for sample
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _socialButton(
                        "Facebook", "assets/images/auth/logo.jpg"),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login",
                    style: TextStyle(color: AppColors.secondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialButton(String label, String iconPath) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Colors.grey),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle,
              color: AppColors.secondary), // Placeholder for social icon
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
