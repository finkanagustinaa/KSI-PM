class UserModel {
  final String id;
  final String nama;
  final String npm;
  final String role; // 'mahasiswa' atau 'dosen'

  UserModel({
    required this.id,
    required this.nama,
    required this.npm,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      nama: json['nama'] ?? 'Pengguna',
      npm: json['npm'] ?? 'N/A',
      role: json['role'] ?? 'mahasiswa',
    );
  }

  Map<String, dynamic> toJson() {
    return {'nama': nama, 'npm': npm, 'role': role};
  }
}
