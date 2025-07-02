import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/achievement_quest_model.dart';
import '../services/firestore_service.dart';

class AchievementQuestService extends GetxService {
  static AchievementQuestService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  /// Lấy tất cả achievement quests của user
  Future<List<AchievementQuestModel>> getAchievementQuests(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievementQuests')
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Tạo achievements mới cho user
        return await _createAchievementQuests(uid);
      }

      final achievements = querySnapshot.docs
          .map((doc) => AchievementQuestModel.fromFirestore(doc))
          .toList();

      // Sort trong memory để tránh cần composite index
      achievements.sort((a, b) {
        final typeComparison = a.type.toString().compareTo(b.type.toString());
        if (typeComparison != 0) return typeComparison;
        return a.tier.compareTo(b.tier);
      });

      return achievements;
    } catch (e) {
      print('❌ Error getting achievement quests: $e');
      return [];
    }
  }

  /// Tạo achievement quests mới cho user
  Future<List<AchievementQuestModel>> _createAchievementQuests(
    String uid,
  ) async {
    try {
      final achievements = AchievementQuestFactory.createAllAchievements();
      final batch = _firestore.batch();

      // Chỉ tạo tier 1 cho mỗi loại achievement
      final tier1Achievements = achievements.where((a) => a.tier == 1).toList();

      for (final achievement in tier1Achievements) {
        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('achievementQuests')
            .doc(achievement.id);
        batch.set(docRef, achievement.toFirestore());
      }

      await batch.commit();
      print('✅ Created achievement quests for $uid');
      return tier1Achievements;
    } catch (e) {
      print('❌ Error creating achievement quests: $e');
      return [];
    }
  }

  /// Cập nhật tiến độ achievement
  Future<bool> updateAchievementProgress(
    String uid,
    AchievementType achievementType, {
    int value = 1,
  }) async {
    try {
      // Lấy achievement hiện tại của type này
      final achievements = await getAchievementQuests(uid);
      final currentAchievements = achievements
          .where(
            (a) =>
                a.type == achievementType &&
                a.status != AchievementStatus.claimed,
          )
          .toList();

      if (currentAchievements.isEmpty) return false;

      // Cập nhật tất cả achievements chưa claim của type này
      final batch = _firestore.batch();
      bool hasUpdate = false;

      for (final achievement in currentAchievements) {
        final updatedAchievement = achievement.updateProgress(value);

        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('achievementQuests')
            .doc(achievement.id);

        batch.update(docRef, updatedAchievement.toFirestore());
        hasUpdate = true;

        // Nếu achievement hoàn thành, tạo achievement tier tiếp theo
        if (updatedAchievement.isCompleted &&
            updatedAchievement.status == AchievementStatus.available) {
          await _createNextTierAchievement(uid, updatedAchievement);
        }
      }

      if (hasUpdate) {
        await batch.commit();
        print(
          '✅ Updated achievement progress: ${achievementType.displayName} +$value',
        );
      }

      return hasUpdate;
    } catch (e) {
      print('❌ Error updating achievement progress: $e');
      return false;
    }
  }

  /// Tạo achievement tier tiếp theo
  Future<void> _createNextTierAchievement(
    String uid,
    AchievementQuestModel completedAchievement,
  ) async {
    try {
      final nextTier = completedAchievement.tier + 1;
      final allAchievements = AchievementQuestFactory.createAllAchievements();

      final nextAchievement = allAchievements.firstWhereOrNull(
        (a) => a.type == completedAchievement.type && a.tier == nextTier,
      );

      if (nextAchievement != null) {
        // Kiểm tra xem achievement này đã tồn tại chưa
        final existingDoc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('achievementQuests')
            .doc(nextAchievement.id)
            .get();

        if (!existingDoc.exists) {
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('achievementQuests')
              .doc(nextAchievement.id)
              .set(nextAchievement.toFirestore());

          print('✅ Created next tier achievement: ${nextAchievement.title}');
        }
      }
    } catch (e) {
      print('❌ Error creating next tier achievement: $e');
    }
  }

  /// Nhận thưởng achievement
  Future<bool> claimAchievementReward(String uid, String achievementId) async {
    try {
      final achievementDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievementQuests')
          .doc(achievementId)
          .get();

      if (!achievementDoc.exists) return false;

      final achievement = AchievementQuestModel.fromFirestore(achievementDoc);
      if (!achievement.isCompleted ||
          achievement.status == AchievementStatus.claimed) {
        return false;
      }

      // Cập nhật trạng thái achievement
      final claimedAchievement = achievement.markAsClaimed();
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('achievementQuests')
          .doc(achievementId)
          .update(claimedAchievement.toFirestore());

      // Thêm phần thưởng cho user
      await _giveRewardToUser(uid, achievement.reward);

      print('✅ Claimed achievement reward: ${achievement.title}');
      return true;
    } catch (e) {
      print('❌ Error claiming achievement reward: $e');
      return false;
    }
  }

  /// Thêm phần thưởng achievement cho user
  Future<void> _giveRewardToUser(String uid, AchievementReward reward) async {
    final futures = <Future>[];

    if (reward.gold > 0) {
      futures.add(_firestoreService.addGoldToUser(uid, reward.gold));
    }
    if (reward.exp > 0) {
      futures.add(_firestoreService.addExpToUser(uid, reward.exp));
    }
    if (reward.diamond > 0) {
      futures.add(_firestoreService.addDiamondToUser(uid, reward.diamond));
    }

    await Future.wait(futures);
  }

  /// Cập nhật đăng nhập liên tiếp
  Future<void> updateConsecutiveLogin(String uid) async {
    try {
      // Lấy thông tin đăng nhập từ collection riêng
      final loginDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('loginStats')
          .doc('consecutive')
          .get();

      int consecutiveDays = 1;
      DateTime? lastLoginDate;

      if (loginDoc.exists) {
        final data = loginDoc.data()!;
        lastLoginDate = (data['lastLoginDate'] as Timestamp?)?.toDate();
        consecutiveDays = data['consecutiveDays'] ?? 1;

        if (lastLoginDate != null) {
          final today = DateTime.now();
          final yesterday = today.subtract(Duration(days: 1));

          // Kiểm tra xem có đăng nhập hôm qua không
          if (_isSameDay(lastLoginDate, yesterday)) {
            consecutiveDays += 1;
          } else if (!_isSameDay(lastLoginDate, today)) {
            // Nếu không đăng nhập hôm qua và không phải hôm nay thì reset
            consecutiveDays = 1;
          }
          // Nếu đã đăng nhập hôm nay rồi thì không làm gì
          else if (_isSameDay(lastLoginDate, today)) {
            return;
          }
        }
      }

      // Cập nhật thông tin đăng nhập
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('loginStats')
          .doc('consecutive')
          .set({
            'consecutiveDays': consecutiveDays,
            'lastLoginDate': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });

      // Cập nhật achievement với giá trị tuyệt đối
      await _updateConsecutiveLoginAchievement(uid, consecutiveDays);

      print('✅ Updated consecutive login: $consecutiveDays days');
    } catch (e) {
      print('❌ Error updating consecutive login: $e');
    }
  }

  /// Cập nhật achievement đăng nhập liên tiếp với giá trị tuyệt đối
  Future<void> _updateConsecutiveLoginAchievement(
    String uid,
    int consecutiveDays,
  ) async {
    try {
      // Lấy achievement hiện tại của consecutive login
      final achievements = await getAchievementQuests(uid);
      final consecutiveLoginAchievements = achievements
          .where(
            (a) =>
                a.type == AchievementType.consecutiveLogin &&
                a.status != AchievementStatus.claimed,
          )
          .toList();

      if (consecutiveLoginAchievements.isEmpty) return;

      final batch = _firestore.batch();
      bool hasUpdate = false;

      for (final achievement in consecutiveLoginAchievements) {
        // Đặt giá trị tuyệt đối thay vì cộng dồn
        if (achievement.currentValue != consecutiveDays) {
          final updatedAchievement = achievement.copyWith(
            currentValue: consecutiveDays,
            status: consecutiveDays >= achievement.targetValue
                ? AchievementStatus.available
                : AchievementStatus.locked,
          );

          final docRef = _firestore
              .collection('users')
              .doc(uid)
              .collection('achievementQuests')
              .doc(achievement.id);

          batch.update(docRef, updatedAchievement.toFirestore());
          hasUpdate = true;

          // Nếu achievement hoàn thành, tạo achievement tier tiếp theo
          if (updatedAchievement.isCompleted &&
              updatedAchievement.status == AchievementStatus.available) {
            await _createNextTierAchievement(uid, updatedAchievement);
          }
        }
      }

      if (hasUpdate) {
        await batch.commit();
        print('✅ Updated consecutive login achievement: $consecutiveDays days');
      }
    } catch (e) {
      print('❌ Error updating consecutive login achievement: $e');
    }
  }

  /// Kiểm tra 2 ngày có giống nhau không
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Lấy số achievement có thể claim
  Future<int> getClaimableAchievementsCount(String uid) async {
    try {
      final achievements = await getAchievementQuests(uid);
      return achievements
          .where((a) => a.status == AchievementStatus.available)
          .length;
    } catch (e) {
      print('❌ Error getting claimable achievements count: $e');
      return 0;
    }
  }

  /// Lấy achievements theo loại
  Future<List<AchievementQuestModel>> getAchievementsByType(
    String uid,
    AchievementType type,
  ) async {
    try {
      final achievements = await getAchievementQuests(uid);
      return achievements.where((a) => a.type == type).toList();
    } catch (e) {
      print('❌ Error getting achievements by type: $e');
      return [];
    }
  }
}
