import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pin_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      _showMessage("All fields must be filled");
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      _showMessage("Password and Confirm Password do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Supabase.instance.client.auth;

      // 1. REGISTER KE SUPABASE AUTH
      final response = await auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user == null) {
        throw "Register failed. Try again.";
      }

      // 2. INSERT KE TABLE PROFILES (PIN KOSONG)
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'role': 'user',
        'user_pin': null,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 3. SIMPAN USER ID KE LOCAL STORAGE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);

      if (!mounted) return;

      _showMessage("Register success! Create your PIN");

      // 4. KE PIN SCREEN (FIRST TIME)
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (_) => const PinScreen(isFirstTime: true),
        ),
            (route) => false,
      );

    } catch (e) {
      _showMessage(e.toString());
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9E8977),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_left,
                    size: 28,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Image.asset(
                'assets/images/logonew.png',
                width: 110,
              ),

              const SizedBox(height: 20),

              const Text(
                "Register",
                style: TextStyle(
                  fontFamily: "Helvetica",
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Create your account and enjoy your coffee",
                style: TextStyle(
                  fontFamily: "Helvetica",
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 35),

              _buildField(
                title: "Email",
                hint: "Email",
                controller: _emailController,
                icon: CupertinoIcons.mail,
              ),

              const SizedBox(height: 22),

              _buildPasswordField(
                title: "Password",
                controller: _passwordController,
              ),

              const SizedBox(height: 22),

              _buildPasswordField(
                title: "Confirm Password",
                controller: _confirmController,
              ),

              const SizedBox(height: 30),

              _buildButton("Register", _register),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Text(
                  "By entering Bakoel Coffee, you have agreed to the\nTerms & Conditions and Privacy Policy",
                  style: TextStyle(color: Colors.white, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // INPUT FIELD
  Widget _buildField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          placeholder: hint,
          prefix: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(icon, color: Colors.grey),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }

  // PASSWORD FIELD
  Widget _buildPasswordField({
    required String title,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          obscureText: _obscure,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(CupertinoIcons.lock, color: Colors.grey),
          ),
          suffix: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() => _obscure = !_obscure);
            },
            child: Icon(
              _obscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
              color: Colors.black,
            ),
          ),
          placeholder: title,
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String title, VoidCallback onPressed) {
    return GestureDetector(
      onTap: _isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFD2BFAA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _isLoading
            ? const CupertinoActivityIndicator()
            : Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
