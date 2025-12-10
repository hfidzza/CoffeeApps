import 'dart:convert';
import 'dart:io';

import 'package:coffee_shop_app/features/user/pages/menu_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({Key? key}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {

  final TextEditingController _manualController =
  TextEditingController(text: "10");

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasScanned = false;

  /// ✅ Fix simulator detection
  bool get isSimulator {
    if (kIsWeb) return true;
    if (Platform.isIOS || Platform.isAndroid) {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _manualController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Scan QR Meja",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        actions: [
          if (!isSimulator)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {
                _scannerController.toggleTorch();
              },
            ),
        ],
      ),
      body: isSimulator
          ? _buildManualInput(context)
          : _buildCameraScanner(context),
    );
  }

  // =============================
  // SIMULATOR MODE
  // =============================
  Widget _buildManualInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Icon(
            Icons.qr_code,
            size: 100,
            color: Colors.brown,
          ),

          const SizedBox(height: 24),

          const Text(
            "Simulator Mode\nMasukkan nomor meja manual",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _manualController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              hintText: "Contoh: 10",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.brown,
              ),
              onPressed: () {
                final text = _manualController.text.trim();

                final tableNumber = int.tryParse(text);

                if (tableNumber == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nomor meja harus angka"),
                    ),
                  );
                  return;
                }

                _goToMenu(context, tableNumber);
              },
              child: const Text(
                "Masuk ke Menu",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // CAMERA MODE
  // =============================
  Widget _buildCameraScanner(BuildContext context) {

    return Stack(
      children: [

        MobileScanner(
          controller: _scannerController,
            onDetect: (capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;

                if (code != null && code.isNotEmpty) {

                  debugPrint("RAW QR: $code");

                  int? tableNumber;

                  try {
                    final data = jsonDecode(code);

                    if (data is Map) {
                      if (data.containsKey('table')) {
                        tableNumber = int.tryParse(data['table'].toString());
                      } else if (data.containsKey('table_number')) {
                        tableNumber = int.tryParse(data['table_number'].toString());
                      }
                    }

                  } catch (e) {
                    debugPrint("ERROR PARSE: $e");

                    // fallback
                    tableNumber = int.tryParse(
                      code.replaceAll(RegExp(r'[^\d]'), ''),
                    );
                  }

                  if (tableNumber != null) {
                    debugPrint("TABLE NUMBER: $tableNumber");

                    _hasScanned = true;
                    _scannerController.stop();

                    _goToMenu(context, tableNumber);
                    break;
                  } else {
                    debugPrint("GAGAL AMBIL NOMOR MEJA");
                  }
                }
              }
            }
        ),

        // Focus box
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        const Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Text(
            "Arahkan kamera ke QR di meja",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

      ],
    );
  }

  // =============================
  // NAVIGATION
  // =============================
  void _goToMenu(BuildContext context, int tableNumber) {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MenuPage(
          tableNumber: tableNumber,
        ),
      ),
    );
  }
}
