import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrTableScreen extends StatelessWidget {
  final int tableNumber;

  const QrTableScreen({Key? key, required this.tableNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String qrData = "coffee://table=$tableNumber";

    return Scaffold(
      appBar: AppBar(
        title: Text("QR Meja $tableNumber"),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: qrData,
              size: 250,
              backgroundColor: Colors.white,
            ),

            const SizedBox(height: 20),

            Text(
              "Scan untuk Meja $tableNumber",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              qrData,
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
