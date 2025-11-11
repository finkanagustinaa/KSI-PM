import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ksi_pm/core/models/course_model.dart';
import 'package:ksi_pm/core/providers/auth_provider.dart';
import 'package:ksi_pm/core/services/firestore_service.dart';

// StreamProvider yang secara otomatis mengambil jadwal saat login
final scheduleProvider = StreamProvider.autoDispose<List<CourseModel>>((ref) {
  //
  final authState = ref.watch(authProvider);

  // Jika belum login atau data user kosong, kembalikan stream kosong
  if (!authState.isLoggedIn || authState.userModel == null) {
    return Stream.value([]); //
  }

  final userModel = authState.userModel!;
  final firestoreService = ref.read(firestoreServiceProvider); //

  // Mengambil jadwal berdasarkan role pengguna
  if (userModel.role == 'mahasiswa') {
    //
    return firestoreService.getJadwalMahasiswa(userModel.id);
  } else if (userModel.role == 'dosen') {
    //
    return firestoreService.getDaftarKelasDosen(userModel.id);
  }

  return Stream.value([]);
});
