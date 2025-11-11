import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class FunctionService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<bool> panggilMarkAttendance(String sessionId, String userId) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('markAttendance');
      final result = await callable.call(<String, dynamic>{
        'sessionId': sessionId,
        'userId': userId,
      });
      // Asumsi Cloud Function mengembalikan {'success': true/false}
      return result.data['success'] ?? false;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Error Mark Attendance: ${e.message}');
      return false;
    }
  }

  Future<String?> panggilGenerateQr(String courseId, String dosenId) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(
        'generateQrSession',
      );
      final result = await callable.call(<String, dynamic>{
        'courseId': courseId,
        'dosenId': dosenId,
      });
      // Asumsi Cloud Function mengembalikan {'sessionId': 'xyz123'}
      return result.data['sessionId'];
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Error Generate QR: ${e.message}');
      return null;
    }
  }
}
