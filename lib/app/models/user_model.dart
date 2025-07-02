import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> providers; // Danh sách các provider: ['email', 'google']

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.providers = const [],
  });

  factory UserModel.fromFirebaseUser(
    String uid,
    String email,
    String? displayName, {
    String? avatarUrl,
    String provider = 'email',
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      createdAt: DateTime.now(),
      providers: [provider],
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      providers: List<String>.from(data['providers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'providers': providers,
    };
  }

  /// Tạo bản sao với các thông tin được cập nhật
  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      providers: providers,
    );
  }

  /// Kiểm tra xem user có provider nào đó không
  bool hasProvider(String provider) {
    return providers.contains(provider);
  }
}
