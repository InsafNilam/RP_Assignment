class UserModel {
  final String name;
  final String status;
  final String uid;
  final String profilePic;
  final bool isOnline;
  final String phoneNumber;
  final List<String> groupId;
  final String token;

  UserModel({
    required this.name,
    required this.status,
    required this.uid,
    required this.profilePic,
    required this.isOnline,
    required this.phoneNumber,
    required this.groupId,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
      'uid': uid,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'groupId': groupId,
      'token': token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      groupId: List<String>.from(
        map['groupId'],
      ),
      token: map['token'] ?? '',
    );
  }
}
