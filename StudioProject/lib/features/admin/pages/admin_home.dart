import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final TextEditingController tableController = TextEditingController();
  int? tableNumber;

  @override
  Widget build(BuildContext context) {
    final String? qrData = tableNumber != null
        ? '{"table_number": $tableNumber}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Generate QR Code Meja",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: tableController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Masukkan nomor meja",
                hintText: "Contoh: 5",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (tableController.text.isNotEmpty) {
                    setState(() {
                      tableNumber = int.parse(tableController.text);
                    });
                  }
                },
                child: const Text("Generate QR"),
              ),
            ),

            const SizedBox(height: 40),

            if (qrData != null) ...[
              QrImageView(
                data: qrData,
                size: 260,
                backgroundColor: Colors.white,
              ),

              const SizedBox(height: 20),

              Text(
                "QR untuk Meja $tableNumber",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
