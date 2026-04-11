import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'register_screen.dart'; 

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF5EDE4);
    const primaryBlue = Color(0xFF4F46E5);
    const hintTextColor = Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Welcome Back! Glad\nTo See You, Again!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter your email and Phone no.',
                  hintStyle: const TextStyle(color: hintTextColor, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(color: hintTextColor, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.visibility_off_outlined, color: hintTextColor),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1, color: Colors.black26)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Or Login with', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  ),
                  Expanded(child: Divider(thickness: 1, color: Colors.black26)),
                ],
              ),
              const SizedBox(height: 24),

              // Social Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialButton(const Icon(Icons.facebook, color: Color(0xFF1877F2))),
                  _buildSocialButton(const Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.red))),
                  _buildSocialButton(const Icon(Icons.apple, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 40),

              // Bottom Text
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text.rich(
                    TextSpan(
                      style: TextStyle(color: Colors.black87, fontSize: 13),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Register Now',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget 
  Widget _buildSocialButton(Widget child) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}