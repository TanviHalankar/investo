class UserModel {
  final String userId;
  final String email;
  final String username;
  final String? displayName;
  final String? photoUrl;
  final DateTime lastLogin;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> portfolio;
  final Map<String, dynamic> settings;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
    this.displayName,
    this.photoUrl,
    required this.lastLogin,
    this.preferences = const {},
    this.portfolio = const {},
    this.settings = const {},
  });

  // Convert UserModel to Map for SharedPreferences storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'lastLogin': lastLogin.millisecondsSinceEpoch,
      'preferences': preferences,
      'portfolio': portfolio,
      'settings': settings,
    };
  }

  // Create UserModel from Map (from SharedPreferences)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      lastLogin: DateTime.fromMillisecondsSinceEpoch(json['lastLogin'] ?? 0),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      portfolio: Map<String, dynamic>.from(json['portfolio'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? userId,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
    DateTime? lastLogin,
    Map<String, dynamic>? preferences,
    Map<String, dynamic>? portfolio,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
      portfolio: portfolio ?? this.portfolio,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, email: $email, username: $username, lastLogin: $lastLogin)';
  }
}
