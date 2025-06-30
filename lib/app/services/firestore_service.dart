import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

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
}
