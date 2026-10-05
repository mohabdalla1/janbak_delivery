enum UserRole {
  customer,
  merchant,
  driver,
  admin,
}

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final UserRole role;
  final String? token;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': role.name,
      'token': token,
    };
  }
}