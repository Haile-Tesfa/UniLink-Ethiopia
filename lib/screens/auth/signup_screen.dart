import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/app_logo.dart';
import '../../utils/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int? _selectedYear;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacementNamed(context, '/home');
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/auth/login_bg.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Center(
                        child: const AppLogo(size: 100),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      const Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 5),
                      
                      const Center(
                        child: Text(
                          'Join UniLink community',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        prefixIcon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      CustomTextField(
                        controller: _emailController,
                        label: 'University Email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter valid email';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      CustomTextField(
                        controller: _studentIdController,
                        label: 'Student ID',
                        prefixIcon: Icons.badge,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter student ID';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      CustomTextField(
                        controller: _departmentController,
                        label: 'Department',
                        prefixIcon: Icons.school,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter department';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Year of Study Dropdown
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Year of Study',
                          prefixIcon: const Icon(Icons.confirmation_number),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            hint: const Text('Select year'),
                            isExpanded: true,
                            items: [1, 2, 3, 4, 5, 6].map((int year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text('Year $year'),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                _selectedYear = value;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        prefixIcon: Icons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      CustomButton(
                        text: 'Create Account',
                        onPressed: _signup,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}