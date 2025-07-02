import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/anime_watch_status_model.dart';

class FirestoreService extends GetxService {
  static FirestoreService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lưu thông tin user
  Future<bool> saveUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));

      print('✅ User saved: ${user.email}');
      return true;
    } catch (e) {
      print('❌ Error saving user: $e');
      return false;
    }
  }

  /// Lưu hoặc cập nhật thông tin user (chỉ cập nhật khi user chưa tồn tại)
  Future<bool> saveUserIfNotExists(UserModel user) async {
    try {
      final existingUser = await getUser(user.uid);

      if (existingUser == null) {
        // User chưa tồn tại, tạo mới
        await _firestore.collection('users').doc(user.uid).set(user.toMap());
        print('✅ New user created: ${user.email}');
      }
      return true;
    } catch (e) {
      print('❌ Error saving user: $e');
      return false;
    }
  }

  /// Lấy thông tin user
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  /// Tìm user theo email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  /// Cập nhật thông tin user
  Future<bool> updateUser(String uid, {
    String? displayName,
    String? avatarUrl,
    int? level,
    int? exp,
    int? gold,
    int? diamond,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (displayName != null) {
        updateData['displayName'] = displayName;
      }

      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }

      if (level != null) {
        updateData['level'] = level;
      }

      if (exp != null) {
        updateData['exp'] = exp;
      }

      if (gold != null) {
        updateData['gold'] = gold;
      }

      if (diamond != null) {
        updateData['diamond'] = diamond;
      }

      print('🔄 Update data: $updateData');

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .update(updateData);

        print('✅ User updated successfully');
        return true;
      }

      print('⚠️ No data to update');
      return true; // Trả về true vì không có lỗi, chỉ là không có gì để cập nhật
    } catch (e) {
      print('❌ Error updating user: $e');
      return false;
    }
  }

  // ==================== USER RESOURCES METHODS ====================

  /// Cập nhật vàng của user
  Future<bool> updateUserGold(String uid, int newGoldAmount) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'gold': newGoldAmount});

      print('✅ User gold updated: $newGoldAmount');
      return true;
    } catch (e) {
      print('❌ Error updating user gold: $e');
      return false;
    }
  }

  /// Cập nhật kim cương của user
  Future<bool> updateUserDiamond(String uid, int newDiamondAmount) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'diamond': newDiamondAmount});

      print('✅ User diamond updated: $newDiamondAmount');
      return true;
    } catch (e) {
      print('❌ Error updating user diamond: $e');
      return false;
    }
  }

  /// Cập nhật level của user
  Future<bool> updateUserLevel(String uid, int newLevel) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'level': newLevel});

      print('✅ User level updated: $newLevel');
      return true;
    } catch (e) {
      print('❌ Error updating user level: $e');
      return false;
    }
  }

  /// Cập nhật EXP của user
  Future<bool> updateUserExp(String uid, int newExp) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'exp': newExp});

      print('✅ User EXP updated: $newExp');
      return true;
    } catch (e) {
      print('❌ Error updating user EXP: $e');
      return false;
    }
  }

  /// Thêm EXP cho user với tự động level up (atomic operation)
  Future<Map<String, dynamic>?> addExpToUser(String uid, int amount) async {
    try {
      Map<String, dynamic>? result;

      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data()!;
        final currentLevel = userData['level'] ?? 1;
        final currentExp = userData['exp'] ?? 0;

        // Tính toán EXP mới
        final newExp = currentExp + amount;

        // Tính toán EXP cần thiết cho level tiếp theo
        final expNeeded = currentLevel * 100 + (currentLevel - 1) * 50;

        if (newExp >= expNeeded) {
          // Level up!
          final remainingExp = newExp - expNeeded;
          final newLevel = currentLevel + 1;

          transaction.update(userRef, {
            'level': newLevel,
            'exp': remainingExp,
          });

          result = {
            'leveledUp': true,
            'oldLevel': currentLevel,
            'newLevel': newLevel,
            'oldExp': currentExp,
            'newExp': remainingExp,
            'expGained': amount,
          };
        } else {
          // Chỉ thêm EXP
          transaction.update(userRef, {'exp': newExp});

          result = {
            'leveledUp': false,
            'level': currentLevel,
            'oldExp': currentExp,
            'newExp': newExp,
            'expGained': amount,
          };
        }
      });

      print('✅ Added $amount EXP to user. Result: $result');
      return result;
    } catch (e) {
      print('❌ Error adding EXP to user: $e');
      return null;
    }
  }

  /// Thêm vàng cho user (atomic operation)
  Future<bool> addGoldToUser(String uid, int amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentGold = userDoc.data()?['gold'] ?? 0;
        final newGold = currentGold + amount;

        transaction.update(userRef, {'gold': newGold});
      });

      print('✅ Added $amount gold to user. New total calculated in transaction.');
      return true;
    } catch (e) {
      print('❌ Error adding gold to user: $e');
      return false;
    }
  }

  /// Trừ vàng của user (atomic operation, không cho phép âm)
  Future<bool> subtractGoldFromUser(String uid, int amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentGold = userDoc.data()?['gold'] ?? 0;
        if (currentGold < amount) {
          throw Exception('Insufficient gold');
        }

        final newGold = currentGold - amount;
        transaction.update(userRef, {'gold': newGold});
      });

      print('✅ Subtracted $amount gold from user.');
      return true;
    } catch (e) {
      print('❌ Error subtracting gold from user: $e');
      return false;
    }
  }

  /// Thêm kim cương cho user (atomic operation)
  Future<bool> addDiamondToUser(String uid, int amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentDiamond = userDoc.data()?['diamond'] ?? 0;
        final newDiamond = currentDiamond + amount;

        transaction.update(userRef, {'diamond': newDiamond});
      });

      print('✅ Added $amount diamond to user. New total calculated in transaction.');
      return true;
    } catch (e) {
      print('❌ Error adding diamond to user: $e');
      return false;
    }
  }

  /// Trừ kim cương của user (atomic operation, không cho phép âm)
  Future<bool> subtractDiamondFromUser(String uid, int amount) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final currentDiamond = userDoc.data()?['diamond'] ?? 0;
        if (currentDiamond < amount) {
          throw Exception('Insufficient diamond');
        }

        final newDiamond = currentDiamond - amount;
        transaction.update(userRef, {'diamond': newDiamond});
      });

      print('✅ Subtracted $amount diamond from user.');
      return true;
    } catch (e) {
      print('❌ Error subtracting diamond from user: $e');
      return false;
    }
  }

  // ==================== ANIME WATCH STATUS METHODS ====================

  /// Lưu hoặc cập nhật trạng thái xem anime
  Future<bool> saveAnimeWatchStatus(String uid, AnimeWatchStatusModel watchStatus) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('animeWatchStatus')
          .doc(watchStatus.malId.toString())
          .set(watchStatus.toFirestore(), SetOptions(merge: true));

      print('✅ Anime watch status saved: ${watchStatus.title} (Status: ${watchStatus.status.displayName})');
      return true;
    } catch (e) {
      print('❌ Error saving anime watch status: $e');
      return false;
    }
  }

  /// Lấy trạng thái xem anime
  Future<AnimeWatchStatusModel?> getAnimeWatchStatus(String uid, int malId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animeWatchStatus')
          .doc(malId.toString())
          .get();

      if (doc.exists) {
        return AnimeWatchStatusModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting anime watch status: $e');
      return null;
    }
  }

  /// Đánh dấu tập anime đã xem
  Future<bool> markEpisodeWatched(String uid, int malId, int episodeIndex, {int? totalEpisodes}) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('animeWatchStatus')
          .doc(malId.toString());

      final doc = await docRef.get();

      if (!doc.exists) {
        print('❌ Anime watch status not found for MAL ID: $malId');
        return false;
      }

      final currentStatus = AnimeWatchStatusModel.fromFirestore(doc);
      final updatedWatchedEpisodes = List<int>.from(currentStatus.watchedEpisodes);

      // Thêm tập vào danh sách đã xem nếu chưa có
      if (!updatedWatchedEpisodes.contains(episodeIndex)) {
        updatedWatchedEpisodes.add(episodeIndex);
        updatedWatchedEpisodes.sort(); // Sắp xếp theo thứ tự
      }

      // Xác định trạng thái mới
      AnimeWatchStatus newStatus;
      // Chỉ sử dụng totalEpisodes từ currentStatus (data detail gốc), không dùng từ nguonc API
      final totalEps = currentStatus.totalEpisodes;

      if (totalEps != null && totalEps > 0 && updatedWatchedEpisodes.length >= totalEps) {
        newStatus = AnimeWatchStatus.completed;
      } else if (updatedWatchedEpisodes.isNotEmpty) {
        newStatus = AnimeWatchStatus.watching;
      } else {
        newStatus = AnimeWatchStatus.saved;
      }

      // Cập nhật document - KHÔNG cập nhật totalEpisodes, giữ nguyên từ data detail
      await docRef.update({
        'status': newStatus.value,
        'currentEpisode': episodeIndex,
        'watchedEpisodes': updatedWatchedEpisodes,
        'lastWatchedAt': FieldValue.serverTimestamp(),
        // Không cập nhật totalEpisodes để giữ nguyên data từ detail
      });

      print('✅ Episode $episodeIndex marked as watched for ${currentStatus.title}');
      print('   📊 Status: ${newStatus.displayName}');
      final progressText = totalEps != null && totalEps > 0
          ? '${updatedWatchedEpisodes.length}/$totalEps episodes'
          : '${updatedWatchedEpisodes.length}/? episodes';
      print('   📺 Progress: $progressText');

      return true;
    } catch (e) {
      print('❌ Error marking episode as watched: $e');
      return false;
    }
  }

  /// Lấy danh sách anime theo trạng thái
  Future<List<AnimeWatchStatusModel>> getAnimesByStatus(String uid, AnimeWatchStatus status) async {
    try {
      // Lấy tất cả anime trước, sau đó filter và sort trong memory để tránh cần index
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animeWatchStatus')
          .get();

      final animes = <AnimeWatchStatusModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          final anime = AnimeWatchStatusModel.fromFirestore(doc);
          // Filter theo status
          if (anime.status == status) {
            animes.add(anime);
          }
        } catch (e) {
          print('❌ Error parsing anime watch status: $e');
        }
      }

      // Sort theo lastWatchedAt descending
      animes.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));

      print('✅ Retrieved ${animes.length} animes with status: ${status.displayName}');
      return animes;
    } catch (e) {
      print('❌ Error getting animes by status: $e');
      return [];
    }
  }

  /// Lấy tất cả anime đã lưu/xem
  Future<List<AnimeWatchStatusModel>> getAllWatchedAnimes(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('animeWatchStatus')
          .get();

      final animes = <AnimeWatchStatusModel>[];
      for (final doc in querySnapshot.docs) {
        try {
          animes.add(AnimeWatchStatusModel.fromFirestore(doc));
        } catch (e) {
          print('❌ Error parsing anime watch status: $e');
        }
      }

      // Sort theo lastWatchedAt descending
      animes.sort((a, b) => b.lastWatchedAt.compareTo(a.lastWatchedAt));

      print('✅ Retrieved ${animes.length} total watched animes');
      return animes;
    } catch (e) {
      print('❌ Error getting all watched animes: $e');
      return [];
    }
  }

  /// Xóa anime khỏi danh sách xem
  Future<bool> removeAnimeWatchStatus(String uid, int malId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('animeWatchStatus')
          .doc(malId.toString())
          .delete();

      print('✅ Anime watch status removed: MAL ID $malId');
      return true;
    } catch (e) {
      print('❌ Error removing anime watch status: $e');
      return false;
    }
  }
}
