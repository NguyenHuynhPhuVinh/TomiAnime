import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/achievement_quest_model.dart';
import '../../../services/achievement_quest_service.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/user_resource_controller.dart';
import '../../../utils/notification_helper.dart';

class AchievementQuestController extends GetxController {
  static AchievementQuestController get instance => Get.find();

  final AchievementQuestService _achievementService = AchievementQuestService.instance;
  final AuthService _authService = AuthService.instance;
  late UserResourceController _userResourceController;

  // Observable data
  RxList<AchievementQuestModel> achievementQuests = <AchievementQuestModel>[].obs;
  RxInt claimableCount = 0.obs;

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isClaimingReward = false.obs;

  // Grouped achievements
  RxList<AchievementQuestModel> consecutiveLoginAchievements = <AchievementQuestModel>[].obs;
  RxList<AchievementQuestModel> animeCompletedAchievements = <AchievementQuestModel>[].obs;
  RxList<AchievementQuestModel> episodesWatchedAchievements = <AchievementQuestModel>[].obs;
  RxList<AchievementQuestModel> animeInfoViewedAchievements = <AchievementQuestModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Khởi tạo UserResourceController nếu chưa có
    if (!Get.isRegistered<UserResourceController>()) {
      Get.put(UserResourceController());
    }
    _userResourceController = UserResourceController.instance;

    // Listen to auth state changes
    ever(_authService.user, (User? user) {
      if (user != null) {
        loadAchievementData();
        _updateConsecutiveLogin();
      } else {
        _clearData();
      }
    });

    // Load initial data if user is already logged in
    if (_authService.isLoggedIn) {
      loadAchievementData();
      _updateConsecutiveLogin();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when page is ready
    loadAchievementData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Tải dữ liệu achievement quests
  Future<void> loadAchievementData() async {
    if (!_authService.isLoggedIn) return;

    try {
      isLoading.value = true;
      final uid = _authService.currentUser!.uid;

      // Load achievements
      final achievements = await _achievementService.getAchievementQuests(uid);
      achievementQuests.value = achievements;

      // Group achievements by type
      _groupAchievements(achievements);

      // Count claimable achievements
      claimableCount.value = achievements.where((a) => a.status == AchievementStatus.available).length;

      print('✅ Achievement data loaded: ${achievements.length} achievements, ${claimableCount.value} claimable');
    } catch (e) {
      print('❌ Error loading achievement data: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể tải dữ liệu thành tựu',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Nhóm achievements theo loại
  void _groupAchievements(List<AchievementQuestModel> achievements) {
    consecutiveLoginAchievements.value = achievements
        .where((a) => a.type == AchievementType.consecutiveLogin)
        .toList()..sort((a, b) => a.tier.compareTo(b.tier));
    
    animeCompletedAchievements.value = achievements
        .where((a) => a.type == AchievementType.animeCompleted)
        .toList()..sort((a, b) => a.tier.compareTo(b.tier));
    
    episodesWatchedAchievements.value = achievements
        .where((a) => a.type == AchievementType.episodesWatched)
        .toList()..sort((a, b) => a.tier.compareTo(b.tier));
    
    animeInfoViewedAchievements.value = achievements
        .where((a) => a.type == AchievementType.animeInfoViewed)
        .toList()..sort((a, b) => a.tier.compareTo(b.tier));
  }

  /// Cập nhật đăng nhập liên tiếp
  Future<void> _updateConsecutiveLogin() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;
    await _achievementService.updateConsecutiveLogin(uid);
    await loadAchievementData(); // Refresh data
  }

  /// Đánh dấu achievement xem tập anime
  Future<void> markWatchEpisodeAchievement() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;
    await _achievementService.updateAchievementProgress(uid, AchievementType.episodesWatched);
    _updateAchievementProgressLocal(AchievementType.episodesWatched, 1);
  }

  /// Đánh dấu achievement hoàn thành anime
  Future<void> markAnimeCompletedAchievement() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;
    await _achievementService.updateAchievementProgress(uid, AchievementType.animeCompleted);
    _updateAchievementProgressLocal(AchievementType.animeCompleted, 1);
  }

  /// Đánh dấu achievement xem thông tin anime
  Future<void> markViewAnimeInfoAchievement() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;
    await _achievementService.updateAchievementProgress(uid, AchievementType.animeInfoViewed);
    _updateAchievementProgressLocal(AchievementType.animeInfoViewed, 1);
  }

  /// Cập nhật tiến độ achievement local
  void _updateAchievementProgressLocal(AchievementType achievementType, int value) {
    final achievements = achievementQuests.where(
      (a) => a.type == achievementType && a.status != AchievementStatus.claimed
    ).toList();

    for (int i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      final achievementIndex = achievementQuests.indexWhere((a) => a.id == achievement.id);
      
      if (achievementIndex != -1) {
        final updatedAchievement = achievement.updateProgress(value);
        achievementQuests[achievementIndex] = updatedAchievement;
        
        // Cập nhật claimable count
        if (updatedAchievement.status == AchievementStatus.available && 
            achievement.status != AchievementStatus.available) {
          claimableCount.value++;
        }
      }
    }

    // Refresh grouped achievements
    _groupAchievements(achievementQuests);
  }

  /// Nhận thưởng achievement
  Future<void> claimAchievementReward(String achievementId) async {
    if (!_authService.isLoggedIn || isClaimingReward.value) return;

    try {
      isClaimingReward.value = true;
      final uid = _authService.currentUser!.uid;
      
      // Tìm achievement trong danh sách local
      final achievementIndex = achievementQuests.indexWhere((a) => a.id == achievementId);
      if (achievementIndex == -1) return;
      
      final achievement = achievementQuests[achievementIndex];
      if (!achievement.isCompleted || achievement.status == AchievementStatus.claimed) return;
      
      final success = await _achievementService.claimAchievementReward(uid, achievementId);
      
      if (success) {
        // Cập nhật local state
        final claimedAchievement = achievement.markAsClaimed();
        achievementQuests[achievementIndex] = claimedAchievement;
        
        // Giảm claimable count
        claimableCount.value--;
        
        // Refresh grouped achievements
        _groupAchievements(achievementQuests);
        
        // Chỉ refresh user resources để cập nhật vàng/EXP/kim cương
        _userResourceController.loadUserData();
        
        NotificationHelper.showSuccess(
          title: 'Thành tựu đạt được!',
          message: '${achievement.title}\n+${achievement.reward.description}',
          duration: Duration(seconds: 3),
        );
      } else {
        NotificationHelper.showError(
          title: 'Lỗi',
          message: 'Không thể nhận thưởng thành tựu',
        );
      }
    } catch (e) {
      print('❌ Error claiming achievement reward: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Đã xảy ra lỗi khi nhận thưởng',
      );
    } finally {
      isClaimingReward.value = false;
    }
  }

  /// Nhận tất cả thưởng có thể
  Future<void> claimAllAvailableRewards() async {
    if (!_authService.isLoggedIn || isClaimingReward.value) return;

    final availableAchievements = achievementQuests
        .where((a) => a.status == AchievementStatus.available)
        .toList();

    if (availableAchievements.isEmpty) {
      NotificationHelper.showInfo(
        title: 'Thông báo',
        message: 'Không có thành tựu nào để nhận thưởng',
      );
      return;
    }

    for (final achievement in availableAchievements) {
      await claimAchievementReward(achievement.id);
      // Thêm delay nhỏ để tránh spam
      await Future.delayed(Duration(milliseconds: 200));
    }
  }

  /// Xóa dữ liệu khi đăng xuất
  void _clearData() {
    achievementQuests.clear();
    consecutiveLoginAchievements.clear();
    animeCompletedAchievements.clear();
    episodesWatchedAchievements.clear();
    animeInfoViewedAchievements.clear();
    claimableCount.value = 0;
  }

  // Getters for UI
  int get totalAchievementsCount => achievementQuests.length;
  int get claimedAchievementsCount => achievementQuests.where((a) => a.status == AchievementStatus.claimed).length;
  double get completionPercentage => totalAchievementsCount > 0 ? claimedAchievementsCount / totalAchievementsCount : 0.0;
}
