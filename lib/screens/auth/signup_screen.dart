import 'package:flutter/material.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _handleSignUp() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details")),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF53B175);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Account 🚀",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                "Sign up to get fresh food delivered at your doorstep.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _handleSignUp,
                  child: const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Log In", style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}