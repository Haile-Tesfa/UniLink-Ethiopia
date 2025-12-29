import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fieldsController;
  late AnimationController _buttonController;

  late Animation<double> _logoAnimation;
  late Animation<double> _fieldsAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Logo fade in
    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn);

    // Input fields fade in
    _fieldsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fieldsAnimation =
        CurvedAnimation(parent: _fieldsController, curve: Curves.easeIn);

    // Button slide up animation
    _buttonController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    // Start animations in sequence
    _logoController.forward().then((_) {
      _fieldsController.forward().then((_) {
        _buttonController.forward();
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fieldsController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient with image overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Image.asset(
            'assets/images/auth/BIT.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.3),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo
                  FadeTransition(
                    opacity: _logoAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset('assets/images/auth/logo.jpg',
                          height: 80),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Animated input fields
                  FadeTransition(
                    opacity: _fieldsAnimation,
                    child: Column(
                      children: [
                        _inputField("Email or phone"),
                        const SizedBox(height: 15),
                        _inputField("Password", isPass: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Animated login button
                  SlideTransition(
                    position: _buttonSlideAnimation,
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(280, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/home'),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
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

  Widget _inputField(String hint, {bool isPass = false}) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon:
              isPass ? const Icon(Icons.lock) : const Icon(Icons.person),
        ),
      ),
    );
  }
}
