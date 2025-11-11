import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. IMPORT RIVERPOD
import 'package:qr_flutter/qr_flutter.dart'; // 2. IMPORT QR_FLUTTER

import '../../core/services/function_service.dart';
import '../../core/providers/auth_provider.dart';

class GenerateQrScreen extends ConsumerStatefulWidget {
  final String courseId;
  // Contoh: const GenerateQrScreen({this.courseId = 'PM301', super.key});
  const GenerateQrScreen({required this.courseId, super.key});

  @override
  ConsumerState<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends ConsumerState<GenerateQrScreen> {
  String? _sessionId;
  bool _isLoading = false;

  Future<void> _generateSession() async {
    // ... (Logika Generate Sesi, sama seperti sebelumnya)
    setState(() {
      _isLoading = true;
      _sessionId = null;
    });

    try {
      final functionService = FunctionService();
      final dosenId = ref.read(authStreamProvider).value?.id;

      if (dosenId == null) throw Exception('Dosen belum login.');

      final newSessionId = await functionService.panggilGenerateQr(
        widget.courseId,
        dosenId,
      );

      if (newSessionId != null) {
        setState(() {
          _sessionId = newSessionId;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal membuat sesi QR.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Generate: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Sesi QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_sessionId == null)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateSession,
                icon: _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.qr_code),
                label: _isLoading
                    ? const Text('Membuat Sesi...')
                    : const Text('MULAI SESI PRESENSI'),
              )
            else
              // Tampilkan QR Code jika _sessionId sudah ada
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: QrImageView(
                  data: _sessionId!,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),

            if (_sessionId != null) ...[
              const SizedBox(height: 20),
              Text(
                'Sesi Aktif: $_sessionId',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'QR Code ini berlaku untuk 5 menit ke depan',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
