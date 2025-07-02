import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestType {
  login,
  watchEpisode,
  onlineTime,
  viewAnimeInfo,
}

enum QuestStatus {
  notStarted,
  inProgress,
  completed,
  claimed,
}

class DailyQuestModel {
  final String id;
  final QuestType type;
  final String title;
  final String description;
  final int targetValue; // Giá trị cần đạt (1 cho đăng nhập, 30 cho online 30 phút, etc.)
  final int currentValue; // Giá trị hiện tại
  final QuestStatus status;
  final QuestReward reward;
  final DateTime createdAt;
  final DateTime? completedAt;

  DailyQuestModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.status = QuestStatus.notStarted,
    required this.reward,
    required this.createdAt,
    this.completedAt,
  });

  /// Kiểm tra xem nhiệm vụ đã hoàn thành chưa
  bool get isCompleted => currentValue >= targetValue;

  /// Tính phần trăm hoàn thành
  double get progressPercentage {
    if (targetValue == 0) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Tạo từ Firestore
  factory DailyQuestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyQuestModel(
      id: doc.id,
      type: QuestType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => QuestType.login,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      targetValue: data['targetValue'] ?? 1,
      currentValue: data['currentValue'] ?? 0,
      status: QuestStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => QuestStatus.notStarted,
      ),
      reward: QuestReward.fromMap(data['reward'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString(),
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'status': status.toString(),
      'reward': reward.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Tạo bản sao với giá trị mới
  DailyQuestModel copyWith({
    int? currentValue,
    QuestStatus? status,
    DateTime? completedAt,
  }) {
    return DailyQuestModel(
      id: id,
      type: type,
      title: title,
      description: description,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      reward: reward,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Cập nhật tiến độ
  DailyQuestModel updateProgress(int value) {
    final newValue = (currentValue + value).clamp(0, targetValue);
    final newStatus = newValue >= targetValue ? QuestStatus.completed : QuestStatus.inProgress;
    final newCompletedAt = newValue >= targetValue ? DateTime.now() : completedAt;

    return copyWith(
      currentValue: newValue,
      status: newStatus,
      completedAt: newCompletedAt,
    );
  }

  /// Đánh dấu đã nhận thưởng
  DailyQuestModel markAsClaimed() {
    return copyWith(status: QuestStatus.claimed);
  }
}

class QuestReward {
  final int gold;
  final int exp;
  final int dailyPoints;

  QuestReward({
    this.gold = 0,
    this.exp = 0,
    this.dailyPoints = 0,
  });

  factory QuestReward.fromMap(Map<String, dynamic> map) {
    return QuestReward(
      gold: map['gold'] ?? 0,
      exp: map['exp'] ?? 0,
      dailyPoints: map['dailyPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gold': gold,
      'exp': exp,
      'dailyPoints': dailyPoints,
    };
  }

  String get description {
    List<String> rewards = [];
    if (gold > 0) rewards.add('$gold vàng');
    if (exp > 0) rewards.add('$exp EXP');
    if (dailyPoints > 0) rewards.add('$dailyPoints điểm ngày');
    return rewards.join(', ');
  }
}

/// Factory để tạo các nhiệm vụ hàng ngày mặc định
class DailyQuestFactory {
  static List<DailyQuestModel> createDefaultQuests(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return [
      DailyQuestModel(
        id: '${dateStr}_login',
        type: QuestType.login,
        title: 'Đăng nhập hàng ngày',
        description: 'Đăng nhập vào ứng dụng',
        targetValue: 1,
        reward: QuestReward(gold: 50, exp: 20, dailyPoints: 1),
        createdAt: date,
      ),
      DailyQuestModel(
        id: '${dateStr}_watch_episode',
        type: QuestType.watchEpisode,
        title: 'Xem tập Anime',
        description: 'Xem 1 tập Anime bất kỳ',
        targetValue: 1,
        reward: QuestReward(gold: 100, exp: 50, dailyPoints: 2),
        createdAt: date,
      ),
      DailyQuestModel(
        id: '${dateStr}_online_time',
        type: QuestType.onlineTime,
        title: 'Thời gian online',
        description: 'Online trong 30 phút',
        targetValue: 30, // 30 phút
        reward: QuestReward(gold: 75, exp: 30, dailyPoints: 1),
        createdAt: date,
      ),
      DailyQuestModel(
        id: '${dateStr}_view_anime_info',
        type: QuestType.viewAnimeInfo,
        title: 'Khám phá Anime',
        description: 'Xem thông tin chi tiết 1 bộ Anime',
        targetValue: 1,
        reward: QuestReward(gold: 25, exp: 15, dailyPoints: 1),
        createdAt: date,
      ),
    ];
  }
}

/// Extension để chuyển đổi QuestType thành icon và màu sắc
extension QuestTypeExtension on QuestType {
  String get iconName {
    switch (this) {
      case QuestType.login:
        return 'login';
      case QuestType.watchEpisode:
        return 'play';
      case QuestType.onlineTime:
        return 'clock';
      case QuestType.viewAnimeInfo:
        return 'info_circle';
    }
  }

  String get displayName {
    switch (this) {
      case QuestType.login:
        return 'Đăng nhập';
      case QuestType.watchEpisode:
        return 'Xem tập';
      case QuestType.onlineTime:
        return 'Online';
      case QuestType.viewAnimeInfo:
        return 'Khám phá';
    }
  }
}

extension QuestStatusExtension on QuestStatus {
  String get displayName {
    switch (this) {
      case QuestStatus.notStarted:
        return 'Chưa bắt đầu';
      case QuestStatus.inProgress:
        return 'Đang thực hiện';
      case QuestStatus.completed:
        return 'Hoàn thành';
      case QuestStatus.claimed:
        return 'Đã nhận thưởng';
    }
  }
}
