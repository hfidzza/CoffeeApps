import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import '../../user/pages/home_screen.dart';

class PinScreen extends StatefulWidget {
  final bool isFirstTime;

  const PinScreen({super.key, required this.isFirstTime});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<String> _pin = ["", "", "", "", "", ""];
  int _currentIndex = 0;
  bool _isLoading = false;

  // --- HASH FUNCTION ---
  String hashPin(String pin, String userId) {
    final bytes = utf8.encode(pin + userId);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // --- NUMPAD INPUT ---
  void _onNumberPressed(String number) {
    if (_currentIndex < 6) {
      setState(() {
        _pin[_currentIndex] = number;
        _currentIndex++;
      });

      if (_currentIndex == 6) {
        widget.isFirstTime ? _savePin() : _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pin[_currentIndex] = "";
      });
    }
  }

  // --- SAVE PIN ---
  Future<void> _savePin() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final pin = _pin.join();
    final hashedPin = hashPin(pin, userId);

    try {
      await supabase
          .from('profiles')
          .update({'user_pin': hashedPin})
          .eq('id', userId);

      await prefs.setBool('has_pin', true);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
      );
    } catch (e) {
      _showError("Failed to save PIN");
    }

    setState(() => _isLoading = false);
  }

  // --- VERIFY PIN ---
  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final inputPin = _pin.join();
    final inputHash = hashPin(inputPin, userId);

    try {
      final response = await supabase
          .from('profiles')
          .select('user_pin')
          .eq('id', userId)
          .single();

      final savedHash = response['user_pin'];

      if (savedHash == inputHash) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
        );
      } else {
        _resetPin();
        _showError("Wrong PIN");
      }
    } catch (e) {
      _showError("Error verifying PIN");
    }

    setState(() => _isLoading = false);
  }

  void _resetPin() {
    setState(() {
      _pin = ["", "", "", "", "", ""];
      _currentIndex = 0;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // --- PIN DOT UI ---
  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pin[index].isEmpty
                ? Colors.white.withOpacity(0.3)
                  : Colors.white,
            ),
          ),
      ),
    );
  }

  // --- NUMPAD UI ---
  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["1", "2", "3"].map(_buildNumberButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["4", "5", "6"].map(_buildNumberButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["7", "8", "9"].map(_buildNumberButton).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70, height: 70),
            _buildNumberButton("0"),
            GestureDetector(
              onTap: _onDelete,
              child: const SizedBox(
                width: 70,
                height: 70,
                child: Icon(Icons.backspace, color: Colors.white),
              ),
            ),
          ],
        )
      ],
    );
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9C8877),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
            ),

            const SizedBox(height: 40),

            Image.asset(
              'assets/images/logonew.png',
              width: 110,
            ),

            const SizedBox(height: 20),

            const Text(
              "Enter PIN",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              widget.isFirstTime
                  ? "Create your 6-digit PIN"
                  : "Enter your registered PIN",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            _buildPinDots(),

            const SizedBox(height: 40),

            if (_isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else
              _buildNumpad(),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                "By entering Bakoel Coffee, you agreed to\nTerms & Conditions and Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
