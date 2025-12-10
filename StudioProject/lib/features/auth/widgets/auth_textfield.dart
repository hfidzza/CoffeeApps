import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthTextfield extends StatefulWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController controller;

  const AuthTextfield({
    super.key,
    required this.hint,
    required this.controller,
    this.isPassword = false,
});

  @override
  State<AuthTextfield> createState() => _AuthTextfieldState();
}

class _AuthTextfieldState extends State<AuthTextfield> {
  bool _obscure = true;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hover ? Colors.white : const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscure : false,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: InputBorder.none,
            contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

            suffixIcon: widget.isPassword
              ? GestureDetector(
                  onTap: () {
                    setState(() => _obscure = !_obscure);
                  },
              child: Icon(
                _obscure
                    ? CupertinoIcons.eye_slash
                    : CupertinoIcons.eye,
              ),
            )
                : null,
          ),
        ),
      ),
    );
  }
}
