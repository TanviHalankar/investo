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
  final Map<String, dynamic> lessons;

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
    this.lessons = const {},
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
      'lessons': lessons,
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
      lessons: Map<String, dynamic>.from(json['lessons'] ?? {}),
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
    Map<String, dynamic>? lessons,
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
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, email: $email, username: $username, lastLogin: $lastLogin)';
  }
}
