import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final List<String> providers; // Danh sách các provider: ['email', 'google']
  final int level; // Level của user
  final int exp; // Kinh nghiệm hiện tại của user
  final int gold; // Số vàng của user
  final int diamond; // Số kim cương của user

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.providers = const [],
    this.level = 1, // Level mặc định là 1
    this.exp = 0, // EXP mặc định là 0
    this.gold = 0, // Vàng mặc định là 0
    this.diamond = 0, // Kim cương mặc định là 0
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
      level: 1, // User mới bắt đầu với level 1
      exp: 0, // User mới bắt đầu với 0 EXP
      gold: 100, // User mới được tặng 100 vàng
      diamond: 10, // User mới được tặng 10 kim cương
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
      level: data['level'] ?? 1,
      exp: data['exp'] ?? 0,
      gold: data['gold'] ?? 0,
      diamond: data['diamond'] ?? 0,
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
      'level': level,
      'exp': exp,
      'gold': gold,
      'diamond': diamond,
    };
  }

  /// Tạo bản sao với các thông tin được cập nhật
  UserModel copyWith({
    String? displayName,
    String? avatarUrl,
    int? level,
    int? exp,
    int? gold,
    int? diamond,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      providers: providers,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      gold: gold ?? this.gold,
      diamond: diamond ?? this.diamond,
    );
  }

  /// Kiểm tra xem user có provider nào đó không
  bool hasProvider(String provider) {
    return providers.contains(provider);
  }

  /// Thêm vàng cho user
  UserModel addGold(int amount) {
    return copyWith(gold: gold + amount);
  }

  /// Trừ vàng của user (không cho phép âm)
  UserModel subtractGold(int amount) {
    final newGold = (gold - amount).clamp(0, double.infinity).toInt();
    return copyWith(gold: newGold);
  }

  /// Thêm kim cương cho user
  UserModel addDiamond(int amount) {
    return copyWith(diamond: diamond + amount);
  }

  /// Trừ kim cương của user (không cho phép âm)
  UserModel subtractDiamond(int amount) {
    final newDiamond = (diamond - amount).clamp(0, double.infinity).toInt();
    return copyWith(diamond: newDiamond);
  }

  /// Thêm EXP cho user và tự động level up nếu đủ điều kiện
  UserModel addExp(int amount) {
    final newExp = exp + amount;
    final expNeeded = experienceNeededForNextLevel;

    if (newExp >= expNeeded) {
      // Level up và reset EXP
      final remainingExp = newExp - expNeeded;
      return copyWith(
        level: level + 1,
        exp: remainingExp,
      );
    } else {
      // Chỉ thêm EXP
      return copyWith(exp: newExp);
    }
  }

  /// Đặt EXP cho user
  UserModel setExp(int newExp) {
    return copyWith(exp: newExp.clamp(0, double.infinity).toInt());
  }

  /// Tăng level cho user (reset EXP về 0)
  UserModel levelUp() {
    return copyWith(level: level + 1, exp: 0);
  }

  /// Đặt level cho user (reset EXP về 0)
  UserModel setLevel(int newLevel) {
    return copyWith(
      level: newLevel.clamp(1, double.infinity).toInt(),
      exp: 0,
    );
  }

  /// Kiểm tra xem user có đủ vàng không
  bool hasEnoughGold(int amount) {
    return gold >= amount;
  }

  /// Kiểm tra xem user có đủ kim cương không
  bool hasEnoughDiamond(int amount) {
    return diamond >= amount;
  }

  /// Tính toán kinh nghiệm cần thiết cho level tiếp theo
  int get experienceNeededForNextLevel {
    // Công thức: level * 100 + (level - 1) * 50
    // Level 1 -> 2: 100 EXP
    // Level 2 -> 3: 250 EXP
    // Level 3 -> 4: 400 EXP
    return level * 100 + (level - 1) * 50;
  }

  /// Tính toán tổng EXP cần thiết để đạt level hiện tại
  int get totalExpForCurrentLevel {
    if (level == 1) return 0;

    int totalExp = 0;
    for (int i = 1; i < level; i++) {
      totalExp += i * 100 + (i - 1) * 50;
    }
    return totalExp;
  }

  /// Tính toán phần trăm EXP hiện tại so với EXP cần thiết cho level tiếp theo
  double get expProgressPercentage {
    final expNeeded = experienceNeededForNextLevel;
    if (expNeeded == 0) return 1.0;
    return (exp / expNeeded).clamp(0.0, 1.0);
  }

  /// Kiểm tra xem có thể level up không
  bool get canLevelUp {
    return exp >= experienceNeededForNextLevel;
  }

  /// Lấy thông tin tóm tắt về tài nguyên của user
  String get resourceSummary {
    return 'Level: $level | EXP: $exp/${experienceNeededForNextLevel} | Vàng: $gold | Kim cương: $diamond';
  }

  /// Lấy thông tin chi tiết về EXP
  String get expDetails {
    return '$exp/${experienceNeededForNextLevel} EXP (${(expProgressPercentage * 100).toStringAsFixed(1)}%)';
  }
}
