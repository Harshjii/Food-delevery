import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;

  void _handleResetPassword() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your registered email")),
      );
      return;
    }

    setState(() => _isSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password reset link sent to your email! 📩"),
        backgroundColor: Color(0xFF53B175),
      ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: brandGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_rounded, size: 36, color: brandGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                "Forgot Password? 🔒",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Don't worry! Enter your email address and we'll send you instructions to reset your password.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintText: "example@mail.com",
                  prefixIcon: const Icon(Icons.email_outlined),
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
                  onPressed: _handleResetPassword,
                  child: Text(
                    _isSent ? "Resend Link" : "Send Reset Link",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}