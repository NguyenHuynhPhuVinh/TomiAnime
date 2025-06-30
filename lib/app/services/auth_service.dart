import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService.instance;
  
  // Observable user state
  Rxn<User> user = Rxn<User>();
  
  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    user.bindStream(_auth.authStateChanges());
  }
  
  // Check if user is logged in
  bool get isLoggedIn => user.value != null;
  
  // Get current user
  User? get currentUser => user.value;
  
  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user to Firestore
      if (credential.user != null) {
        await _saveUserToFirestore(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi không xác định: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user to Firestore
      if (credential.user != null) {
        await _saveUserToFirestore(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi không xác định: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔍 Starting Google Sign-In...');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('🔍 Google user: $googleUser');
      
      if (googleUser == null) {
        // User canceled the sign-in
        print('🔍 User canceled Google Sign-In');
        return null;
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      print('🔍 Signing in to Firebase...');
      final result = await _auth.signInWithCredential(credential);
      print('🔍 Firebase sign-in successful: ${result.user?.email}');

      // Save user to Firestore
      if (result.user != null) {
        await _saveUserToFirestore(result.user!);
      }

      return result;
    } catch (e) {
      print('🔍 Google Sign-In error: $e');
      Get.snackbar(
        'Lỗi',
        'Đăng nhập Google thất bại: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đăng xuất thất bại: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Thành công',
        'Email đặt lại mật khẩu đã được gửi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi không xác định: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
  
  // Handle Firebase Auth errors
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'Không tìm thấy tài khoản với email này';
        break;
      case 'wrong-password':
        message = 'Mật khẩu không chính xác';
        break;
      case 'email-already-in-use':
        message = 'Email này đã được sử dụng';
        break;
      case 'weak-password':
        message = 'Mật khẩu quá yếu';
        break;
      case 'invalid-email':
        message = 'Email không hợp lệ';
        break;
      case 'user-disabled':
        message = 'Tài khoản đã bị vô hiệu hóa';
        break;
      case 'too-many-requests':
        message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
        break;
      case 'operation-not-allowed':
        message = 'Phương thức đăng nhập này không được phép';
        break;
      default:
        message = 'Đã xảy ra lỗi: ${e.message}';
    }
    
    Get.snackbar(
      'Lỗi đăng nhập',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Save user to Firestore (chỉ tạo mới nếu chưa tồn tại)
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userModel = UserModel.fromFirebaseUser(
        user.uid,
        user.email ?? '',
        user.displayName,
      );

      await _firestoreService.saveUserIfNotExists(userModel);
    } catch (e) {
      print('❌ Error saving user to Firestore: $e');
    }
  }
}
