import 'package:cloud_firestore/cloud_firestore.dart';

enum AchievementType {
  consecutiveLogin,
  animeCompleted,
  episodesWatched,
  animeInfoViewed,
}

enum AchievementStatus {
  locked,
  available,
  claimed,
}

class AchievementQuestModel {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final int tier; // Cấp độ: 1, 2, 3, 4, 5...
  final int targetValue; // Giá trị cần đạt
  final int currentValue; // Giá trị hiện tại
  final AchievementStatus status;
  final AchievementReward reward;
  final DateTime createdAt;
  final DateTime? claimedAt;

  AchievementQuestModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.tier,
    required this.targetValue,
    this.currentValue = 0,
    this.status = AchievementStatus.locked,
    required this.reward,
    required this.createdAt,
    this.claimedAt,
  });

  /// Kiểm tra xem achievement đã hoàn thành chưa
  bool get isCompleted => currentValue >= targetValue;

  /// Tính phần trăm hoàn thành
  double get progressPercentage {
    if (targetValue == 0) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Tạo từ Firestore
  factory AchievementQuestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AchievementQuestModel(
      id: doc.id,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => AchievementType.consecutiveLogin,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      tier: data['tier'] ?? 1,
      targetValue: data['targetValue'] ?? 1,
      currentValue: data['currentValue'] ?? 0,
      status: AchievementStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => AchievementStatus.locked,
      ),
      reward: AchievementReward.fromMap(data['reward'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      claimedAt: (data['claimedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString(),
      'title': title,
      'description': description,
      'tier': tier,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'status': status.toString(),
      'reward': reward.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'claimedAt': claimedAt != null ? Timestamp.fromDate(claimedAt!) : null,
    };
  }

  /// Tạo bản sao với giá trị mới
  AchievementQuestModel copyWith({
    int? currentValue,
    AchievementStatus? status,
    DateTime? claimedAt,
  }) {
    return AchievementQuestModel(
      id: id,
      type: type,
      title: title,
      description: description,
      tier: tier,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      reward: reward,
      createdAt: createdAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  /// Cập nhật tiến độ
  AchievementQuestModel updateProgress(int value) {
    final newValue = (currentValue + value).clamp(0, double.infinity).toInt();
    final newStatus = newValue >= targetValue ? AchievementStatus.available : status;

    return copyWith(
      currentValue: newValue,
      status: newStatus,
    );
  }

  /// Đánh dấu đã nhận thưởng
  AchievementQuestModel markAsClaimed() {
    return copyWith(
      status: AchievementStatus.claimed,
      claimedAt: DateTime.now(),
    );
  }

  /// Lấy achievement tiếp theo (tier + 1)
  String get nextAchievementId {
    return '${type.toString()}_tier_${tier + 1}';
  }
}

class AchievementReward {
  final int gold;
  final int exp;
  final int diamond;

  AchievementReward({
    this.gold = 0,
    this.exp = 0,
    this.diamond = 0,
  });

  factory AchievementReward.fromMap(Map<String, dynamic> map) {
    return AchievementReward(
      gold: map['gold'] ?? 0,
      exp: map['exp'] ?? 0,
      diamond: map['diamond'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gold': gold,
      'exp': exp,
      'diamond': diamond,
    };
  }

  String get description {
    List<String> rewards = [];
    if (gold > 0) rewards.add('$gold vàng');
    if (exp > 0) rewards.add('$exp EXP');
    if (diamond > 0) rewards.add('$diamond kim cương');
    return rewards.join(', ');
  }
}

/// Factory để tạo các achievement quest
class AchievementQuestFactory {
  /// Tạo achievement đăng nhập liên tiếp
  static List<AchievementQuestModel> createConsecutiveLoginAchievements() {
    final achievements = <AchievementQuestModel>[];
    final targets = [1, 3, 7, 15, 30, 60, 100];
    
    for (int i = 0; i < targets.length; i++) {
      final tier = i + 1;
      final target = targets[i];
      final baseReward = tier * 100;
      
      achievements.add(AchievementQuestModel(
        id: 'consecutiveLogin_tier_$tier',
        type: AchievementType.consecutiveLogin,
        title: 'Đăng nhập ${target} ngày',
        description: 'Đăng nhập liên tiếp $target ngày',
        tier: tier,
        targetValue: target,
        reward: AchievementReward(
          gold: baseReward,
          exp: baseReward ~/ 2,
          diamond: tier >= 3 ? tier : 0,
        ),
        createdAt: DateTime.now(),
      ));
    }
    
    return achievements;
  }

  /// Tạo achievement hoàn thành anime
  static List<AchievementQuestModel> createAnimeCompletedAchievements() {
    final achievements = <AchievementQuestModel>[];
    final targets = [1, 3, 5, 10, 20, 50, 100];
    
    for (int i = 0; i < targets.length; i++) {
      final tier = i + 1;
      final target = targets[i];
      final baseReward = tier * 150;
      
      achievements.add(AchievementQuestModel(
        id: 'animeCompleted_tier_$tier',
        type: AchievementType.animeCompleted,
        title: 'Hoàn thành ${target} bộ anime',
        description: 'Xem hết $target bộ anime',
        tier: tier,
        targetValue: target,
        reward: AchievementReward(
          gold: baseReward,
          exp: baseReward,
          diamond: tier >= 2 ? tier * 2 : 0,
        ),
        createdAt: DateTime.now(),
      ));
    }
    
    return achievements;
  }

  /// Tạo achievement xem tập
  static List<AchievementQuestModel> createEpisodesWatchedAchievements() {
    final achievements = <AchievementQuestModel>[];
    final targets = [10, 50, 100, 250, 500, 1000, 2000];
    
    for (int i = 0; i < targets.length; i++) {
      final tier = i + 1;
      final target = targets[i];
      final baseReward = tier * 80;
      
      achievements.add(AchievementQuestModel(
        id: 'episodesWatched_tier_$tier',
        type: AchievementType.episodesWatched,
        title: 'Xem ${target} tập',
        description: 'Xem tổng cộng $target tập anime',
        tier: tier,
        targetValue: target,
        reward: AchievementReward(
          gold: baseReward,
          exp: baseReward ~/ 2,
          diamond: tier >= 3 ? tier : 0,
        ),
        createdAt: DateTime.now(),
      ));
    }
    
    return achievements;
  }

  /// Tạo achievement xem thông tin anime
  static List<AchievementQuestModel> createAnimeInfoViewedAchievements() {
    final achievements = <AchievementQuestModel>[];
    final targets = [10, 25, 50, 100, 200, 500];
    
    for (int i = 0; i < targets.length; i++) {
      final tier = i + 1;
      final target = targets[i];
      final baseReward = tier * 60;
      
      achievements.add(AchievementQuestModel(
        id: 'animeInfoViewed_tier_$tier',
        type: AchievementType.animeInfoViewed,
        title: 'Khám phá ${target} anime',
        description: 'Xem thông tin $target bộ anime',
        tier: tier,
        targetValue: target,
        reward: AchievementReward(
          gold: baseReward,
          exp: baseReward ~/ 3,
          diamond: tier >= 4 ? tier - 2 : 0,
        ),
        createdAt: DateTime.now(),
      ));
    }
    
    return achievements;
  }

  /// Tạo tất cả achievements
  static List<AchievementQuestModel> createAllAchievements() {
    return [
      ...createConsecutiveLoginAchievements(),
      ...createAnimeCompletedAchievements(),
      ...createEpisodesWatchedAchievements(),
      ...createAnimeInfoViewedAchievements(),
    ];
  }
}

/// Extension để lấy thông tin hiển thị
extension AchievementTypeExtension on AchievementType {
  String get iconName {
    switch (this) {
      case AchievementType.consecutiveLogin:
        return 'calendar';
      case AchievementType.animeCompleted:
        return 'medal_star';
      case AchievementType.episodesWatched:
        return 'video_play';
      case AchievementType.animeInfoViewed:
        return 'search_normal';
    }
  }

  String get displayName {
    switch (this) {
      case AchievementType.consecutiveLogin:
        return 'Đăng nhập';
      case AchievementType.animeCompleted:
        return 'Hoàn thành';
      case AchievementType.episodesWatched:
        return 'Xem tập';
      case AchievementType.animeInfoViewed:
        return 'Khám phá';
    }
  }

  String get categoryName {
    switch (this) {
      case AchievementType.consecutiveLogin:
        return 'Chăm chỉ';
      case AchievementType.animeCompleted:
        return 'Thành tựu';
      case AchievementType.episodesWatched:
        return 'Kinh nghiệm';
      case AchievementType.animeInfoViewed:
        return 'Khám phá';
    }
  }
}

extension AchievementStatusExtension on AchievementStatus {
  String get displayName {
    switch (this) {
      case AchievementStatus.locked:
        return 'Đã khóa';
      case AchievementStatus.available:
        return 'Có thể nhận';
      case AchievementStatus.claimed:
        return 'Đã nhận';
    }
  }
}
