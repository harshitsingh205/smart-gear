class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double? heightCm;
  final double? weightKg;
  final int? age;
  final String? preferredDestination;
  final String role; // 'rider' or 'admin'
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.heightCm,
    this.weightKg,
    this.age,
    this.preferredDestination,
    this.role = 'rider',
    this.photoUrl,
  });

  bool get isAdmin => role == 'admin';

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? heightCm,
    double? weightKg,
    int? age,
    String? preferredDestination,
    String? role,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      preferredDestination: preferredDestination ?? this.preferredDestination,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'age': age,
      'preferredDestination': preferredDestination,
      'role': role,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      age: json['age'] as int?,
      preferredDestination: json['preferredDestination'] as String?,
      role: json['role'] as String? ?? 'rider',
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
