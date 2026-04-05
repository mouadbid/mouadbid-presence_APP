import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'student_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? errorMsg = await ApiService.login(_emailController.text.trim(), _passwordController.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (errorMsg == null) {
      if (ApiService.currentUserRole == 'etudiant') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Modern background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modern Logo Area
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(Icons.school_rounded, size: 60, color: Colors.blueAccent),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'ESTC Présence',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blueGrey),
              ),
              const SizedBox(height: 8),
              Text(
                'Connectez-vous pour gérer vos séances.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blueGrey[400], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 48),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Email Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Adresse Email',
                    hintText: 'email@estc.ma',
                    prefixIcon: const Icon(Icons.alternate_email_rounded, color: Colors.blueAccent),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.blueAccent),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.blueGrey[300]),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Login Button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
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
