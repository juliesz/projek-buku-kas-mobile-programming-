class UserAccount {
  final String? id;
  final String username;
  final String password;
  final String fullName;

  UserAccount({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id']?.toString(),
      username: json['username'] as String,
      password: json['password'] as String? ?? '',
      fullName: json['fullName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
    };
  }
}