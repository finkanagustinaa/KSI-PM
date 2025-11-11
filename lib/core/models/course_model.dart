class CourseModel {
  final String id;
  final String namaMatkul;
  final String kodeMK;
  final String dosen;
  final String? waktu;
  final String? ruang;

  CourseModel({
    required this.id,
    required this.namaMatkul,
    required this.kodeMK,
    required this.dosen,
    this.waktu,
    this.ruang,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json, String id) {
    return CourseModel(
      id: id,
      namaMatkul: json['namaMatkul'] ?? 'Mata Kuliah Tidak Dikenal',
      kodeMK: json['kodeMK'] ?? 'N/A',
      dosen: json['dosen'] ?? 'Dosen Belum Ditentukan',
      waktu: json['waktu'],
      ruang: json['ruang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namaMatkul': namaMatkul,
      'kodeMK': kodeMK,
      'dosen': dosen,
      'waktu': waktu,
      'ruang': ruang,
    };
  }
}
