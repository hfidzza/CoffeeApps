import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin/pages/admin_home.dart';
import '../../user/pages/home_screen.dart';
import '../../onboarding/pages/onboarding_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgotEmailController = TextEditingController();

  bool _obscure = true;
  bool _showForgot = false;
  bool _isLoading = false;

  late AnimationController _forgotController;
  late Animation<Offset> _forgotAnimation;

  @override
  void initState() {
    super.initState();

    _forgotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _forgotAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _forgotController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    /// Saat animasi selesai REVERSE -> baru hide widget
    _forgotController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() => _showForgot = false);
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    _forgotController.dispose();
    super.dispose();
  }

  // ================= LOGIN ==================
  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage("Email and password required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = res.user;

      if (user == null) throw "Login failed";

      // ✅ Save user_id ke local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);

      // ✅ Ambil role & PIN dari table profiles
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role, user_pin')
          .eq('id', user.id)
          .single();

      final role = profile['role'];
      final userPin = profile['user_pin'];

      if (!mounted) return;

      // ✅ ADMIN langsung ke AdminHome
      if (role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
              (route) => false,
        );
        return;
      }

      // ✅ USER → cek PIN
      if (userPin == null || userPin.toString().isEmpty) {
        // BELUM ADA PIN
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const PinScreen(isFirstTime: true),
          ),
              (route) => false,
        );
      } else {
        // SUDAH ADA PIN
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      _showMessage(e.toString());
    }

    setState(() => _isLoading = false);
  }


  // =========== RESET PASSWORD ===========
  Future<void> _sendResetPassword() async {
    if (forgotEmailController.text.isEmpty) {
      _showMessage("Enter your email");
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        forgotEmailController.text.trim(),
      );

      _showMessage("Check your email for reset link");

      // Slide down
      _forgotController.reverse();
    } catch (e) {
      _showMessage(e.toString());
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ================= UI ===================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9E8977),
      body: Stack(
        children: [

          /// MAIN PAGE
          AbsorbPointer(
            absorbing: _showForgot,
            child: Opacity(
              opacity: _showForgot ? 0.25 : 1,
              child: SafeArea(
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
                              MaterialPageRoute(
                                  builder: (_) => OnboardingScreen()),
                            );
                          },
                          child: const Icon(
                            CupertinoIcons.arrow_left,
                            size: 28,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Image.asset(
                        'assets/images/logonew.png',
                        width: 110,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Welcome",
                        style: TextStyle(
                          fontFamily: "Helvetica",
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: -2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Sign In your account and enjoy your coffee",
                        style: TextStyle(
                          fontFamily: "Helvetica",
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      _buildField(
                        title: "Email",
                        hint: "Email",
                        controller: emailController,
                        icon: CupertinoIcons.mail,
                      ),

                      const SizedBox(height: 20),

                      _buildPasswordField(),

                      Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _showForgot = true;
                            });
                            _forgotController.forward(from: 0);
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildButton("Login", _login),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don’t have an account? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 80),
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
            ),
          ),

          /// ===== FORGOT PASSWORD PANEL =====
          if (_showForgot)
            SlideTransition(
              position: _forgotAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.53,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F140B),
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      const Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontFamily: "Helvetica",
                          letterSpacing: -1,
                          color: Colors.white70,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      _buildField(
                        title: "Email",
                        hint: "Email",
                        controller: forgotEmailController,
                        icon: CupertinoIcons.mail,
                      ),

                      const SizedBox(height: 30),

                      _buildButton("Send", _sendResetPassword),

                      const SizedBox(height: 20),

                      CupertinoButton(
                        onPressed: () {
                          _forgotController.reverse();
                        },
                        child: const Text(
                          "Close",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= INPUT FIELD ==================
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
            color: const Color(0xffececec),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }

  // ================= PASSWORD ==================
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: passwordController,
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
          placeholder: 'Password',
          decoration: BoxDecoration(
            color: const Color(0xffececec),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ],
    );
  }

  // ================= BUTTON ==================
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
