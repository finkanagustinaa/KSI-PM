import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Inisialisasi Firebase Admin SDK (hanya sekali)
admin.initializeApp();
const db = admin.firestore();

/* * FUNGSI 1: Dipanggil Dosen untuk membuat sesi QR
 */
export const generateQrSession = functions.https.onCall(async (data, context) => {
  // Validasi 1: Autentikasi
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Harus login.");
  }
  const userId = context.auth.uid;
  const courseId = data.courseId; // Matakuliah yang dipilih Dosen

  // Validasi 2: Role Dosen
  const userDoc = await db.collection("users").doc(userId).get();
  if (userDoc.data()?.role !== "dosen") {
    throw new functions.https.HttpsError("permission-denied", "Hanya Dosen.");
  }

  // Validasi 3: Kepemilikan Matakuliah
  const courseDoc = await db.collection("courses").doc(courseId).get();
  if (courseDoc.data()?.dosenId !== userId) {
    throw new functions.https.HttpsError("permission-denied", "Bukan matakuliah Anda.");
  }

  // Logika Inti: Buat Sesi
  const durasiMenit = 10; // QR valid 10 menit
  const waktuBuka = admin.firestore.Timestamp.now();
  const waktuTutup = admin.firestore.Timestamp.fromMillis(
    waktuBuka.toMillis() + durasiMenit * 60 * 1000,
  );

  const sessionRef = await db.collection("attendance_sessions").add({
    courseId: courseId,
    dosenId: userId,
    waktuBuka: waktuBuka,
    waktuTutup: waktuTutup,
    status: "open",
  });

  // Kembalikan ID Sesi ke aplikasi Dosen untuk dijadikan QR
  return { sessionId: sessionRef.id };
});

/* * FUNGSI 2: Dipanggil Mahasiswa saat scan QR
 */
export const markAttendance = functions.https.onCall(async (data, context) => {
  // Validasi 1: Autentikasi
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Harus login.");
  }
  const userId = context.auth.uid;
  const sessionId = data.sessionId; // Didapat dari hasil scan QR

  // Validasi 2: Role Mahasiswa
  const userDoc = await db.collection("users").doc(userId).get();
  if (userDoc.data()?.role !== "mahasiswa") {
    throw new functions.https.HttpsError("permission-denied", "Hanya Mahasiswa.");
  }

  // Validasi 3: Cek Sesi
  const sessionRef = db.collection("attendance_sessions").doc(sessionId);
  const sessionDoc = await sessionRef.get();
  if (!sessionDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Sesi tidak valid.");
  }
  const sessionData = sessionDoc.data()!;

  // Validasi 4: Cek Waktu & Status
  if (sessionData.status !== "open") {
    throw new functions.https.HttpsError("failed-precondition", "Sesi ditutup.");
  }
  if (admin.firestore.Timestamp.now() > sessionData.waktuTutup) {
    await sessionRef.update({ status: "closed" }); // Tutup jika terlewat
    throw new functions.https.HttpsError("deadline-exceeded", "Waktu habis.");
  }

  // Validasi 5: Cek Keterdaftar (PENTING)
  const courseDoc = await db.collection("courses").doc(sessionData.courseId).get();
  if (!courseDoc.data()?.daftarMahasiswa.includes(userId)) {
    throw new functions.https.HttpsError("permission-denied", "Tidak terdaftar.");
  }

  // Validasi 6: Cek Double Absen
  const recordQuery = await db.collection("attendance_records")
    .where("sessionId", "==", sessionId)
    .where("userId", "==", userId)
    .get();
  if (!recordQuery.empty) {
    throw new functions.https.HttpsError("already-exists", "Sudah absen.");
  }

  // Logika Inti: Catat Absen!
  await db.collection("attendance_records").add({
    sessionId: sessionId,
    userId: userId,
    courseId: sessionData.courseId,
    timestamp: admin.firestore.Timestamp.now(),
    status: "hadir",
  });

  return { success: true, message: "Absensi berhasil dicatat!" };
});

/* * FUNGSI 3: Berjalan otomatis untuk membersihkan sesi
 */
export const closeExpiredSessions = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const query = db.collection("attendance_sessions")
      .where("status", "==", "open")
      .where("waktuTutup", "<=", now);

    const snapshot = await query.get();
    if (snapshot.empty) return null;

    const batch = db.batch();
    snapshot.forEach((doc) => {
      batch.update(doc.ref, { status: "closed" });
    });

    await batch.commit();
    return null;
  });