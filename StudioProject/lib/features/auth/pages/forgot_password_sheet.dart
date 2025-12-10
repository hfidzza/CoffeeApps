import 'package:flutter/material.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/main_button.dart';

class ForgotPasswordSheet extends StatelessWidget {
  ForgotPasswordSheet({super.key});

  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .6,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1308),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 30),

          AuthTextfield(
            hint: "Email", controller: emailController),

          const SizedBox(height: 20),

          MainButton(
            text: "Send",
            onTap: () {
              // TODO: Integrasi supabase reset password
            },
          )
        ],
      ),
    );
  }
}
