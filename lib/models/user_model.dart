class User {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    this.role = UserRole.customer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      email: data['email'] ?? '',
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      role: UserRole.values.firstWhere(
        (role) =>
            role.toString().split('.').last == (data['role'] ?? 'customer'),
        orElse: () => UserRole.customer,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserRole {
  customer,
  seller,
  admin,
}
