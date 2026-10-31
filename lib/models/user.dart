class User {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  String toString() => fullName;
}
