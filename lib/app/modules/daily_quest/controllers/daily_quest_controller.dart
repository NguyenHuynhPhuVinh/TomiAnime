import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/daily_quest_model.dart';
import '../../../models/daily_reward_chest_model.dart';
import '../../../services/daily_quest_service.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/user_resource_controller.dart';
import '../../../utils/notification_helper.dart';

class DailyQuestController extends GetxController {
  static DailyQuestController get instance => Get.find();

  final DailyQuestService _questService = DailyQuestService.instance;
  final AuthService _authService = AuthService.instance;
  late UserResourceController _userResourceController;

  // Observable data
  RxList<DailyQuestModel> dailyQuests = <DailyQuestModel>[].obs;
  RxList<DailyRewardChestModel> rewardChests = <DailyRewardChestModel>[].obs;
  RxInt currentDailyPoints = 0.obs;

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isClaimingReward = false.obs;
  RxBool isOpeningChest = false.obs;

  // Online time tracking
  DateTime? _sessionStartTime;
  RxInt onlineMinutes = 0.obs;

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
        loadDailyData();
        _startOnlineTimeTracking();
        _markLoginQuest();
      } else {
        _stopOnlineTimeTracking();
        _clearData();
      }
    });

    // Load initial data if user is already logged in
    if (_authService.isLoggedIn) {
      loadDailyData();
      _startOnlineTimeTracking();
      _markLoginQuest();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh data when page is ready
    loadDailyData();
  }

  @override
  void onClose() {
    _stopOnlineTimeTracking();
    super.onClose();
  }

  /// Tải dữ liệu nhiệm vụ hàng ngày
  Future<void> loadDailyData() async {
    if (!_authService.isLoggedIn) return;

    try {
      isLoading.value = true;
      final uid = _authService.currentUser!.uid;
      final today = DateTime.now();

      // Load quests and chests
      final [quests, chests] = await Future.wait([
        _questService.getDailyQuests(uid, today),
        _questService.getDailyRewardChests(uid, today),
      ]);

      dailyQuests.value = quests as List<DailyQuestModel>;
      rewardChests.value = chests as List<DailyRewardChestModel>;

      // Load daily points
      currentDailyPoints.value = await _questService.getCurrentDailyPoints(uid);

      print('✅ Daily data loaded: ${dailyQuests.length} quests, ${rewardChests.length} chests, ${currentDailyPoints.value} points');
    } catch (e) {
      print('❌ Error loading daily data: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể tải dữ liệu nhiệm vụ hàng ngày',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Đánh dấu nhiệm vụ đăng nhập
  Future<void> _markLoginQuest() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;
    await _questService.updateQuestProgress(uid, QuestType.login);
    _updateQuestProgressLocal(QuestType.login, 1);
  }

  /// Đánh dấu nhiệm vụ xem tập anime
  Future<void> markWatchEpisodeQuest() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;

    // Cập nhật cả 2 nhiệm vụ: xem 1 tập và xem 3 tập
    await Future.wait([
      _questService.updateQuestProgress(uid, QuestType.watchEpisode),
      _questService.updateQuestProgress(uid, QuestType.watchMultipleEpisodes),
    ]);

    _updateQuestProgressLocal(QuestType.watchEpisode, 1);
    _updateQuestProgressLocal(QuestType.watchMultipleEpisodes, 1);

    // Kiểm tra xem có nhiệm vụ nào vừa hoàn thành không
    final watchEpisodeQuest = dailyQuests.firstWhereOrNull((q) => q.type == QuestType.watchEpisode);
    final watchMultipleQuest = dailyQuests.firstWhereOrNull((q) => q.type == QuestType.watchMultipleEpisodes);

    if (watchEpisodeQuest?.isCompleted == true && watchEpisodeQuest?.status != QuestStatus.claimed) {
      NotificationHelper.showSuccess(
        title: 'Nhiệm vụ hoàn thành!',
        message: 'Đã hoàn thành nhiệm vụ xem tập anime!',
      );
    }

    if (watchMultipleQuest?.isCompleted == true && watchMultipleQuest?.status != QuestStatus.claimed) {
      NotificationHelper.showSuccess(
        title: 'Nhiệm vụ hoàn thành!',
        message: 'Đã hoàn thành nhiệm vụ xem 3 tập anime!',
      );
    }
  }

  /// Đánh dấu nhiệm vụ xem thông tin anime
  Future<void> markViewAnimeInfoQuest() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;
    final success = await _questService.updateQuestProgress(uid, QuestType.viewAnimeInfo);

    if (success) {
      _updateQuestProgressLocal(QuestType.viewAnimeInfo, 1);
      NotificationHelper.showSuccess(
        title: 'Nhiệm vụ cập nhật',
        message: 'Đã hoàn thành nhiệm vụ khám phá anime!',
      );
    }
  }

  /// Cập nhật tiến độ nhiệm vụ local
  void _updateQuestProgressLocal(QuestType questType, int value) {
    final questIndex = dailyQuests.indexWhere((q) => q.type == questType);
    if (questIndex == -1) return;

    final quest = dailyQuests[questIndex];
    if (quest.status == QuestStatus.claimed) return;

    final updatedQuest = quest.updateProgress(value);
    dailyQuests[questIndex] = updatedQuest;
  }

  /// Nhận thưởng nhiệm vụ
  Future<void> claimQuestReward(String questId) async {
    if (!_authService.isLoggedIn || isClaimingReward.value) return;

    try {
      isClaimingReward.value = true;
      final uid = _authService.currentUser!.uid;

      // Tìm quest trong danh sách local
      final questIndex = dailyQuests.indexWhere((q) => q.id == questId);
      if (questIndex == -1) return;

      final quest = dailyQuests[questIndex];
      if (!quest.isCompleted || quest.status == QuestStatus.claimed) return;

      final success = await _questService.claimQuestReward(uid, questId);

      if (success) {
        // Cập nhật local state thay vì reload
        final updatedQuest = quest.markAsClaimed();
        dailyQuests[questIndex] = updatedQuest;

        // Cập nhật điểm ngày local
        currentDailyPoints.value += quest.reward.dailyPoints;

        // Kiểm tra và mở khóa hòm quà local
        _updateChestsLocalState();

        // Chỉ refresh user resources để cập nhật vàng/EXP
        _userResourceController.loadUserData();

        NotificationHelper.showSuccess(
          title: 'Thành công',
          message: 'Đã nhận thưởng: ${quest.reward.description}',
        );
      } else {
        NotificationHelper.showError(
          title: 'Lỗi',
          message: 'Không thể nhận thưởng nhiệm vụ',
        );
      }
    } catch (e) {
      print('❌ Error claiming quest reward: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Đã xảy ra lỗi khi nhận thưởng',
      );
    } finally {
      isClaimingReward.value = false;
    }
  }

  /// Mở hòm quà
  Future<void> openRewardChest(String chestId) async {
    if (!_authService.isLoggedIn || isOpeningChest.value) return;

    try {
      isOpeningChest.value = true;
      final uid = _authService.currentUser!.uid;

      // Tìm chest trong danh sách local
      final chestIndex = rewardChests.indexWhere((c) => c.id == chestId);
      if (chestIndex == -1) return;

      final chest = rewardChests[chestIndex];
      if (chest.status != ChestStatus.available) return;

      final success = await _questService.openRewardChest(uid, chestId);

      if (success) {
        // Cập nhật local state
        final openedChest = chest.open();
        rewardChests[chestIndex] = openedChest;

        // Chỉ refresh user resources để cập nhật kim cương
        _userResourceController.loadUserData();

        NotificationHelper.showSuccess(
          title: 'Chúc mừng!',
          message: 'Đã nhận: ${chest.reward.description}',
        );
      } else {
        NotificationHelper.showError(
          title: 'Lỗi',
          message: 'Không thể mở hòm quà. Kiểm tra điểm ngày của bạn.',
        );
      }
    } catch (e) {
      print('❌ Error opening reward chest: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Đã xảy ra lỗi khi mở hòm quà',
      );
    } finally {
      isOpeningChest.value = false;
    }
  }

  /// Cập nhật trạng thái hòm quà local khi điểm ngày thay đổi
  void _updateChestsLocalState() {
    final points = currentDailyPoints.value;

    for (int i = 0; i < rewardChests.length; i++) {
      final chest = rewardChests[i];
      if (chest.status == ChestStatus.locked && points >= chest.requiredDailyPoints) {
        rewardChests[i] = chest.unlock();
      }
    }
  }

  /// Bắt đầu theo dõi thời gian online
  void _startOnlineTimeTracking() {
    _sessionStartTime = DateTime.now();

    // Cập nhật thời gian online mỗi phút
    ever(onlineMinutes, (int minutes) {
      if (minutes > 0 && minutes % 30 == 0) {
        _updateOnlineTimeQuest();
      }
    });

    // Timer để cập nhật thời gian online
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      if (_sessionStartTime != null) {
        final currentMinutes = DateTime.now().difference(_sessionStartTime!).inMinutes;
        onlineMinutes.value = currentMinutes;
      }
    });
  }

  /// Dừng theo dõi thời gian online
  void _stopOnlineTimeTracking() {
    _sessionStartTime = null;
    onlineMinutes.value = 0;
  }

  /// Cập nhật nhiệm vụ thời gian online
  Future<void> _updateOnlineTimeQuest() async {
    if (!_authService.isLoggedIn) return;

    final uid = _authService.currentUser!.uid;
    await _questService.updateQuestProgress(uid, QuestType.onlineTime, value: 30);
    await loadDailyData(); // Refresh data
  }

  /// Xóa dữ liệu khi đăng xuất
  void _clearData() {
    dailyQuests.clear();
    rewardChests.clear();
    currentDailyPoints.value = 0;
    onlineMinutes.value = 0;
  }

  // Getters for UI
  int get completedQuestsCount => dailyQuests.where((q) => q.isCompleted).length;
  int get totalQuestsCount => dailyQuests.length;
  int get availableChestsCount => rewardChests.where((c) => c.status == ChestStatus.available).length;
  double get dailyProgress => totalQuestsCount > 0 ? completedQuestsCount / totalQuestsCount : 0.0;
}
