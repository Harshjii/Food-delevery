import 'package:flutter/material.dart';
import '../admin/admin_panel_screen.dart';
import '../home/home_screen.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _proceedToHome() {
    // Check if logging in as Admin
    if (_emailController.text.trim().toLowerCase() == "admin@food.com") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
      );
      return;
    }

    // Default: Go to Customer Home Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ZYVO brand primary orange
    const brandOrange = Color(0xFFFF5E00);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ZYVO Official Brand Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 85,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback agar image path me koi typo ho
                    return const Text(
                      "ZYVO",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: brandOrange,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                "Welcome Back! 👋",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 6),
              Text(
                "Order your favorite local food fresh & fast.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email or Phone",
                  prefixIcon: const Icon(Icons.email_outlined),
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: brandOrange, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _proceedToHome,
                  child: const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 30, color: Colors.redAccent),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                  onPressed: _proceedToHome,
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text("Sign Up", style: TextStyle(color: brandOrange, fontWeight: FontWeight.bold)),
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