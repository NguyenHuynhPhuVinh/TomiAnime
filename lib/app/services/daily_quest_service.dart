import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/daily_quest_model.dart';
import '../models/daily_reward_chest_model.dart';
import '../services/firestore_service.dart';

class DailyQuestService extends GetxService {
  static DailyQuestService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  /// Lấy nhiệm vụ hàng ngày của user
  Future<List<DailyQuestModel>> getDailyQuests(
    String uid,
    DateTime date,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyQuests')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_getStartOfDay(date)),
          )
          .where(
            'createdAt',
            isLessThan: Timestamp.fromDate(_getEndOfDay(date)),
          )
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Tạo nhiệm vụ mới cho ngày hôm nay
        return await _createDailyQuests(uid, date);
      }

      return querySnapshot.docs
          .map((doc) => DailyQuestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting daily quests: $e');
      return [];
    }
  }

  /// Lấy hòm quà hàng ngày của user
  Future<List<DailyRewardChestModel>> getDailyRewardChests(
    String uid,
    DateTime date,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyRewardChests')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_getStartOfDay(date)),
          )
          .where(
            'createdAt',
            isLessThan: Timestamp.fromDate(_getEndOfDay(date)),
          )
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Tạo hòm quà mới cho ngày hôm nay
        return await _createDailyRewardChests(uid, date);
      }

      return querySnapshot.docs
          .map((doc) => DailyRewardChestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Error getting daily reward chests: $e');
      return [];
    }
  }

  /// Tạo nhiệm vụ hàng ngày mới
  Future<List<DailyQuestModel>> _createDailyQuests(
    String uid,
    DateTime date,
  ) async {
    try {
      final quests = DailyQuestFactory.createDefaultQuests(date);
      final batch = _firestore.batch();

      for (final quest in quests) {
        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('dailyQuests')
            .doc(quest.id);
        batch.set(docRef, quest.toFirestore());
      }

      await batch.commit();
      print('✅ Created daily quests for $uid');
      return quests;
    } catch (e) {
      print('❌ Error creating daily quests: $e');
      return [];
    }
  }

  /// Tạo hòm quà hàng ngày mới
  Future<List<DailyRewardChestModel>> _createDailyRewardChests(
    String uid,
    DateTime date,
  ) async {
    try {
      final chests = DailyRewardChestFactory.createDefaultChests(date);
      final batch = _firestore.batch();

      for (final chest in chests) {
        final docRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('dailyRewardChests')
            .doc(chest.id);
        batch.set(docRef, chest.toFirestore());
      }

      await batch.commit();
      print('✅ Created daily reward chests for $uid');
      return chests;
    } catch (e) {
      print('❌ Error creating daily reward chests: $e');
      return [];
    }
  }

  /// Cập nhật tiến độ nhiệm vụ
  Future<bool> updateQuestProgress(
    String uid,
    QuestType questType, {
    int value = 1,
  }) async {
    try {
      final today = DateTime.now();
      final quests = await getDailyQuests(uid, today);

      final quest = quests.firstWhereOrNull((q) => q.type == questType);
      if (quest == null || quest.status == QuestStatus.claimed) {
        return false;
      }

      final updatedQuest = quest.updateProgress(value);

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyQuests')
          .doc(quest.id)
          .update(updatedQuest.toFirestore());

      print(
        '✅ Updated quest progress: ${questType.displayName} - ${updatedQuest.currentValue}/${updatedQuest.targetValue}',
      );
      return true;
    } catch (e) {
      print('❌ Error updating quest progress: $e');
      return false;
    }
  }

  /// Nhận thưởng nhiệm vụ
  Future<bool> claimQuestReward(String uid, String questId) async {
    try {
      final questDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyQuests')
          .doc(questId)
          .get();

      if (!questDoc.exists) return false;

      final quest = DailyQuestModel.fromFirestore(questDoc);
      if (!quest.isCompleted || quest.status == QuestStatus.claimed) {
        return false;
      }

      // Cập nhật trạng thái nhiệm vụ
      final claimedQuest = quest.markAsClaimed();
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyQuests')
          .doc(questId)
          .update(claimedQuest.toFirestore());

      // Thêm phần thưởng cho user
      await _giveRewardToUser(uid, quest.reward);

      // Cập nhật điểm ngày và kiểm tra hòm quà
      await _updateDailyPointsAndCheckChests(uid, quest.reward.dailyPoints);

      print('✅ Claimed quest reward: ${quest.title}');
      return true;
    } catch (e) {
      print('❌ Error claiming quest reward: $e');
      return false;
    }
  }

  /// Mở hòm quà
  Future<bool> openRewardChest(String uid, String chestId) async {
    try {
      final chestDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyRewardChests')
          .doc(chestId)
          .get();

      if (!chestDoc.exists) return false;

      final chest = DailyRewardChestModel.fromFirestore(chestDoc);
      if (chest.status != ChestStatus.available) {
        return false;
      }

      // Kiểm tra điểm ngày
      final dailyPoints = await _getCurrentDailyPoints(uid);
      if (dailyPoints < chest.requiredDailyPoints) {
        return false;
      }

      // Mở hòm quà
      final openedChest = chest.open();
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyRewardChests')
          .doc(chestId)
          .update(openedChest.toFirestore());

      // Thêm phần thưởng cho user
      await _giveChestRewardToUser(uid, chest.reward);

      print('✅ Opened reward chest: ${chest.title}');
      return true;
    } catch (e) {
      print('❌ Error opening reward chest: $e');
      return false;
    }
  }

  /// Thêm phần thưởng nhiệm vụ cho user
  Future<void> _giveRewardToUser(String uid, QuestReward reward) async {
    if (reward.gold > 0) {
      await _firestoreService.addGoldToUser(uid, reward.gold);
    }
    if (reward.exp > 0) {
      await _firestoreService.addExpToUser(uid, reward.exp);
    }
  }

  /// Thêm phần thưởng hòm quà cho user
  Future<void> _giveChestRewardToUser(String uid, ChestReward reward) async {
    if (reward.gold > 0) {
      await _firestoreService.addGoldToUser(uid, reward.gold);
    }
    if (reward.diamond > 0) {
      await _firestoreService.addDiamondToUser(uid, reward.diamond);
    }
    if (reward.exp > 0) {
      await _firestoreService.addExpToUser(uid, reward.exp);
    }
  }

  /// Cập nhật điểm ngày và kiểm tra hòm quà
  Future<void> _updateDailyPointsAndCheckChests(String uid, int points) async {
    try {
      final today = DateTime.now();
      final dailyPoints = await _getCurrentDailyPoints(uid) + points;

      // Lưu điểm ngày
      await _saveDailyPoints(uid, dailyPoints, today);

      // Kiểm tra và mở khóa hòm quà
      final chests = await getDailyRewardChests(uid, today);
      for (final chest in chests) {
        if (chest.status == ChestStatus.locked &&
            dailyPoints >= chest.requiredDailyPoints) {
          final unlockedChest = chest.unlock();
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('dailyRewardChests')
              .doc(chest.id)
              .update(unlockedChest.toFirestore());
        }
      }
    } catch (e) {
      print('❌ Error updating daily points: $e');
    }
  }

  /// Lấy điểm ngày hiện tại (public method)
  Future<int> getCurrentDailyPoints(String uid) async {
    return await _getCurrentDailyPoints(uid);
  }

  /// Lấy điểm ngày hiện tại (private method)
  Future<int> _getCurrentDailyPoints(String uid) async {
    try {
      final today = DateTime.now();
      final dateStr = _getDateString(today);

      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyProgress')
          .doc(dateStr)
          .get();

      if (doc.exists) {
        return doc.data()?['dailyPoints'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error getting daily points: $e');
      return 0;
    }
  }

  /// Lưu điểm ngày
  Future<void> _saveDailyPoints(String uid, int points, DateTime date) async {
    try {
      final dateStr = _getDateString(date);
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('dailyProgress')
          .doc(dateStr)
          .set({
            'dailyPoints': points,
            'date': Timestamp.fromDate(date),
            'updatedAt': Timestamp.now(),
          }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Error saving daily points: $e');
    }
  }

  /// Helper methods
  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}
