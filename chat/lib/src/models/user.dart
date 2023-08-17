class User {
  User({
    required this.username,
    required this.photoUrl,
    required this.active,
    required this.lastSeen,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    final User user = User(
      username: json['username'] as String,
      photoUrl: json['photoUrl'] as String,
      active: json['active'] as bool,
      lastSeen: json['lastSeen'] as DateTime,
    );
    user._id = json['id'] as String;
    return user;
  }
  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;
  String? _id;
  String? get id => _id;

  Map<String, Object> toJson() => {
        'username': username,
        'photoUrl': photoUrl,
        'active': active,
        'lastSeen': lastSeen
      };
  @override
  String toString() {
    return 'User{username: $username, photoUrl: $photoUrl, active: $active, lastSeen: $lastSeen}';
  }
}
