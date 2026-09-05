class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String avatar;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      avatar: map['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}
