import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/notification_helper.dart';

class UserResourceController extends GetxController {
  static UserResourceController get instance => Get.find();

  final FirestoreService _firestoreService = FirestoreService.instance;
  final AuthService _authService = AuthService.instance;

  // Observable user data
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  // Loading states
  RxBool isLoading = false.obs;
  RxBool isUpdatingExp = false.obs;
  RxBool isUpdatingGold = false.obs;
  RxBool isUpdatingDiamond = false.obs;
  RxBool isUpdatingLevel = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes and load user data
    ever(_authService.user, (User? user) {
      if (user != null) {
        loadUserData();
      } else {
        currentUser.value = null;
      }
    });

    // Load initial data if user is already logged in
    if (_authService.isLoggedIn) {
      loadUserData();
    }
  }

  /// Tải dữ liệu user từ Firestore
  Future<void> loadUserData() async {
    if (!_authService.isLoggedIn) return;

    try {
      isLoading.value = true;
      final userData = await _firestoreService.getUser(_authService.currentUser!.uid);
      
      if (userData != null) {
        currentUser.value = userData;
        print('✅ User data loaded: ${userData.resourceSummary}');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể tải dữ liệu người dùng',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Thêm EXP cho user với tự động level up
  Future<bool> addExp(int amount) async {
    if (!_authService.isLoggedIn || currentUser.value == null) return false;

    try {
      isUpdatingExp.value = true;

      final result = await _firestoreService.addExpToUser(
        _authService.currentUser!.uid,
        amount,
      );

      if (result != null) {
        if (result['leveledUp'] == true) {
          // Level up!
          currentUser.value = currentUser.value!.copyWith(
            level: result['newLevel'],
            exp: result['newExp'],
          );

          NotificationHelper.showSuccess(
            title: 'Chúc mừng!',
            message: 'Bạn đã lên Level ${result['newLevel']}! (+${amount} EXP)',
            duration: const Duration(seconds: 4),
          );
        } else {
          // Chỉ thêm EXP
          currentUser.value = currentUser.value!.copyWith(
            exp: result['newExp'],
          );

          NotificationHelper.showSuccess(
            title: 'Nhận EXP',
            message: '+${amount} EXP (${result['newExp']}/${currentUser.value!.experienceNeededForNextLevel})',
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Error adding EXP: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể thêm EXP',
      );
      return false;
    } finally {
      isUpdatingExp.value = false;
    }
  }

  /// Thêm vàng cho user
  Future<bool> addGold(int amount) async {
    if (!_authService.isLoggedIn || currentUser.value == null) return false;

    try {
      isUpdatingGold.value = true;
      
      final success = await _firestoreService.addGoldToUser(
        _authService.currentUser!.uid,
        amount,
      );

      if (success) {
        // Cập nhật local state
        currentUser.value = currentUser.value!.addGold(amount);
        
        NotificationHelper.showSuccess(
          title: 'Thành công',
          message: 'Đã nhận $amount vàng!',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error adding gold: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể thêm vàng',
      );
      return false;
    } finally {
      isUpdatingGold.value = false;
    }
  }

  /// Trừ vàng của user
  Future<bool> subtractGold(int amount) async {
    if (!_authService.isLoggedIn || currentUser.value == null) return false;

    // Kiểm tra xem user có đủ vàng không
    if (!currentUser.value!.hasEnoughGold(amount)) {
      NotificationHelper.showError(
        title: 'Không đủ vàng',
        message: 'Bạn cần $amount vàng nhưng chỉ có ${currentUser.value!.gold} vàng',
      );
      return false;
    }

    try {
      isUpdatingGold.value = true;
      
      final success = await _firestoreService.subtractGoldFromUser(
        _authService.currentUser!.uid,
        amount,
      );

      if (success) {
        // Cập nhật local state
        currentUser.value = currentUser.value!.subtractGold(amount);
        
        NotificationHelper.showInfo(
          title: 'Đã sử dụng',
          message: 'Đã sử dụng $amount vàng',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error subtracting gold: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể sử dụng vàng',
      );
      return false;
    } finally {
      isUpdatingGold.value = false;
    }
  }

  /// Thêm kim cương cho user
  Future<bool> addDiamond(int amount) async {
    if (!_authService.isLoggedIn || currentUser.value == null) return false;

    try {
      isUpdatingDiamond.value = true;
      
      final success = await _firestoreService.addDiamondToUser(
        _authService.currentUser!.uid,
        amount,
      );

      if (success) {
        // Cập nhật local state
        currentUser.value = currentUser.value!.addDiamond(amount);
        
        NotificationHelper.showSuccess(
          title: 'Thành công',
          message: 'Đã nhận $amount kim cương!',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error adding diamond: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể thêm kim cương',
      );
      return false;
    } finally {
      isUpdatingDiamond.value = false;
    }
  }

  /// Trừ kim cương của user
  Future<bool> subtractDiamond(int amount) async {
    if (!_authService.isLoggedIn || currentUser.value == null) return false;

    // Kiểm tra xem user có đủ kim cương không
    if (!currentUser.value!.hasEnoughDiamond(amount)) {
      NotificationHelper.showError(
        title: 'Không đủ kim cương',
        message: 'Bạn cần $amount kim cương nhưng chỉ có ${currentUser.value!.diamond} kim cương',
      );
      return false;
    }

    try {
      isUpdatingDiamond.value = true;
      
      final success = await _firestoreService.subtractDiamondFromUser(
        _authService.currentUser!.uid,
        amount,
      );

      if (success) {
        // Cập nhật local state
        currentUser.value = currentUser.value!.subtractDiamond(amount);
        
        NotificationHelper.showInfo(
          title: 'Đã sử dụng',
          message: 'Đã sử dụng $amount kim cương',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error subtracting diamond: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể sử dụng kim cương',
      );
      return false;
    } finally {
      isUpdatingDiamond.value = false;
    }
  }

  /// Tăng level cho user
  Future<bool> levelUp() async {
    if (!_authService.isLoggedIn || currentUser.value == null) return false;

    try {
      isUpdatingLevel.value = true;
      
      final newLevel = currentUser.value!.level + 1;
      final success = await _firestoreService.updateUserLevel(
        _authService.currentUser!.uid,
        newLevel,
      );

      if (success) {
        // Cập nhật local state
        currentUser.value = currentUser.value!.levelUp();
        
        NotificationHelper.showSuccess(
          title: 'Chúc mừng!',
          message: 'Bạn đã lên level $newLevel!',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error leveling up: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể tăng level',
      );
      return false;
    } finally {
      isUpdatingLevel.value = false;
    }
  }

  /// Đặt level cho user
  Future<bool> setLevel(int level) async {
    if (!_authService.isLoggedIn || currentUser.value == null) return false;

    try {
      isUpdatingLevel.value = true;
      
      final success = await _firestoreService.updateUserLevel(
        _authService.currentUser!.uid,
        level,
      );

      if (success) {
        // Cập nhật local state
        currentUser.value = currentUser.value!.setLevel(level);
        
        NotificationHelper.showInfo(
          title: 'Cập nhật',
          message: 'Level đã được đặt thành $level',
        );
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error setting level: $e');
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Không thể đặt level',
      );
      return false;
    } finally {
      isUpdatingLevel.value = false;
    }
  }

  // Getters for easy access
  int get userLevel => currentUser.value?.level ?? 1;
  int get userExp => currentUser.value?.exp ?? 0;
  int get userGold => currentUser.value?.gold ?? 0;
  int get userDiamond => currentUser.value?.diamond ?? 0;
  String get resourceSummary => currentUser.value?.resourceSummary ?? 'Chưa có dữ liệu';
  String get expDetails => currentUser.value?.expDetails ?? '0/100 EXP (0%)';
  double get expProgress => currentUser.value?.expProgressPercentage ?? 0.0;
  bool get canLevelUp => currentUser.value?.canLevelUp ?? false;
}
