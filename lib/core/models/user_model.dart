class UserModel {
  final String uid;
  final String name;
  final String npm;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.npm,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      npm: map['npm'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'uid': uid, 'name': name, 'npm': npm, 'role': role};
  }
}
