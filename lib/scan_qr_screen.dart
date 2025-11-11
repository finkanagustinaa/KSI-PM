import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Package mobile_scanner
import '../../core/providers/auth_provider.dart';
import '../../core/services/function_service.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;

  Future<void> _processQrCode(String sessionId) async {
    if (_isProcessing) return; // Mencegah pemrosesan ganda

    setState(() {
      _isProcessing = true;
      _isScanning = false;
    });

    try {
      final functionService = FunctionService(); // Ambil service
      final userId = ref.read(authStreamProvider).value?.id; // Ambil ID user dari provider

      if (userId == null) {
        throw Exception('User belum login.');
      }

      final success = await functionService.panggilMarkAttendance(sessionId, userId);

      // Tampilkan hasil ke user
      String message = success ? 'Presensi Berhasil!' : 'Presensi Gagal! Coba lagi.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      // Tunggu sebentar lalu mulai scan lagi
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isScanning = true; // Aktifkan scan kembali
        });
        _scannerController.start(); // Mulai kamera lagi
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Presensi')),
      body: MobileScanner(
        controller: _scannerController,
        // Saat QR terdeteksi, ambil data dan proses
        onDetect: (capture) {
          if (_isScanning) {
            final String? sessionId = capture.barcodes.first.rawValue;
            if (sessionId != null) {
              _scannerController.stop(); // Hentikan kamera sementara
              _processQrCode(sessionId);
            }
          }
        },
        overlay: Container(
          // Tambahkan overlay visual untuk panduan scanning 
          decoration: BoxDecoration(
            border: Border.all(color: _isProcessing ? Colors.orange : Colors.white, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          margin: const EdgeInsets.all(50),
          child: _isProcessing 
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.green))
            : const Text('Arahkan ke QR Code Sesi', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}