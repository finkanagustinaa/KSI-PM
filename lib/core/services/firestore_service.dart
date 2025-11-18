import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      // Tangani error, logging
      return null;
    }
  }

  Stream<List<CourseModel>> getJadwalMahasiswa(String userId) {
    // Asumsi: Ada koleksi 'userCourses' yang menyimpan ID kursus yang diikuti user
    return _firestore
        .collection('userCourses')
        .doc(userId)
        .collection('courses')
        .snapshots()
        .asyncMap((snapshot) async {
          List<CourseModel> courses = [];
          for (var doc in snapshot.docs) {
            final courseDoc = await _firestore
                .collection('courses')
                .doc(doc.id)
                .get();
            if (courseDoc.exists) {
              courses.add(
                CourseModel.fromJson(courseDoc.data()!, courseDoc.id),
              );
            }
          }
          return courses;
        });
  }

  // getDaftarKelasDosen() (Jika Role Dosen)
}
