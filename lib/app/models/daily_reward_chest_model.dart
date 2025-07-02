import 'package:cloud_firestore/cloud_firestore.dart';

enum ChestType {
  bronze,
  silver,
  gold,
  diamond,
}

enum ChestStatus {
  locked,
  available,
  opened,
}

class DailyRewardChestModel {
  final String id;
  final ChestType type;
  final String title;
  final String description;
  final int requiredDailyPoints; // Số điểm ngày cần thiết để mở khóa
  final ChestReward reward;
  final ChestStatus status;
  final DateTime createdAt;
  final DateTime? openedAt;

  DailyRewardChestModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.requiredDailyPoints,
    required this.reward,
    this.status = ChestStatus.locked,
    required this.createdAt,
    this.openedAt,
  });

  /// Tạo từ Firestore
  factory DailyRewardChestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyRewardChestModel(
      id: doc.id,
      type: ChestType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => ChestType.bronze,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requiredDailyPoints: data['requiredDailyPoints'] ?? 1,
      reward: ChestReward.fromMap(data['reward'] ?? {}),
      status: ChestStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => ChestStatus.locked,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      openedAt: (data['openedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Chuyển thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.toString(),
      'title': title,
      'description': description,
      'requiredDailyPoints': requiredDailyPoints,
      'reward': reward.toMap(),
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'openedAt': openedAt != null ? Timestamp.fromDate(openedAt!) : null,
    };
  }

  /// Tạo bản sao với trạng thái mới
  DailyRewardChestModel copyWith({
    ChestStatus? status,
    DateTime? openedAt,
  }) {
    return DailyRewardChestModel(
      id: id,
      type: type,
      title: title,
      description: description,
      requiredDailyPoints: requiredDailyPoints,
      reward: reward,
      status: status ?? this.status,
      createdAt: createdAt,
      openedAt: openedAt ?? this.openedAt,
    );
  }

  /// Mở khóa hòm quà
  DailyRewardChestModel unlock() {
    return copyWith(status: ChestStatus.available);
  }

  /// Mở hòm quà
  DailyRewardChestModel open() {
    return copyWith(
      status: ChestStatus.opened,
      openedAt: DateTime.now(),
    );
  }
}

class ChestReward {
  final int gold;
  final int diamond;
  final int exp;

  ChestReward({
    this.gold = 0,
    this.diamond = 0,
    this.exp = 0,
  });

  factory ChestReward.fromMap(Map<String, dynamic> map) {
    return ChestReward(
      gold: map['gold'] ?? 0,
      diamond: map['diamond'] ?? 0,
      exp: map['exp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gold': gold,
      'diamond': diamond,
      'exp': exp,
    };
  }

  String get description {
    List<String> rewards = [];
    if (gold > 0) rewards.add('$gold vàng');
    if (diamond > 0) rewards.add('$diamond kim cương');
    if (exp > 0) rewards.add('$exp EXP');
    return rewards.join(', ');
  }
}

/// Factory để tạo các hòm quà hàng ngày mặc định
class DailyRewardChestFactory {
  static List<DailyRewardChestModel> createDefaultChests(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return [
      DailyRewardChestModel(
        id: '${dateStr}_bronze',
        type: ChestType.bronze,
        title: 'Hòm Đồng',
        description: 'Hòm quà cơ bản',
        requiredDailyPoints: 2,
        reward: ChestReward(gold: 50, diamond: 1),
        createdAt: date,
      ),
      DailyRewardChestModel(
        id: '${dateStr}_silver',
        type: ChestType.silver,
        title: 'Hòm Bạc',
        description: 'Hòm quà tốt',
        requiredDailyPoints: 4,
        reward: ChestReward(gold: 100, diamond: 3, exp: 50),
        createdAt: date,
      ),
      DailyRewardChestModel(
        id: '${dateStr}_gold',
        type: ChestType.gold,
        title: 'Hòm Vàng',
        description: 'Hòm quà cao cấp',
        requiredDailyPoints: 5,
        reward: ChestReward(gold: 200, diamond: 5, exp: 100),
        createdAt: date,
      ),
    ];
  }
}

/// Extension để lấy màu sắc và icon cho từng loại hòm
extension ChestTypeExtension on ChestType {
  String get iconName {
    switch (this) {
      case ChestType.bronze:
        return 'gift';
      case ChestType.silver:
        return 'gift';
      case ChestType.gold:
        return 'gift';
      case ChestType.diamond:
        return 'gift';
    }
  }

  String get colorName {
    switch (this) {
      case ChestType.bronze:
        return 'brown';
      case ChestType.silver:
        return 'grey';
      case ChestType.gold:
        return 'amber';
      case ChestType.diamond:
        return 'cyan';
    }
  }

  String get displayName {
    switch (this) {
      case ChestType.bronze:
        return 'Hòm Đồng';
      case ChestType.silver:
        return 'Hòm Bạc';
      case ChestType.gold:
        return 'Hòm Vàng';
      case ChestType.diamond:
        return 'Hòm Kim Cương';
    }
  }
}

extension ChestStatusExtension on ChestStatus {
  String get displayName {
    switch (this) {
      case ChestStatus.locked:
        return 'Đã khóa';
      case ChestStatus.available:
        return 'Có thể mở';
      case ChestStatus.opened:
        return 'Đã mở';
    }
  }
}
