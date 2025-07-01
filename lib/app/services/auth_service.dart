import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
import '../utils/notification_helper.dart';

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
      NotificationHelper.showError(
        title: 'Lỗi đăng nhập',
        message: 'Đã xảy ra lỗi không xác định: $e',
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
      NotificationHelper.showError(
        title: 'Lỗi đăng ký',
        message: 'Đã xảy ra lỗi không xác định: $e',
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
      NotificationHelper.showError(
        title: 'Lỗi đăng nhập Google',
        message: 'Đăng nhập Google thất bại: $e',
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
      NotificationHelper.showError(
        title: 'Lỗi đăng xuất',
        message: 'Đăng xuất thất bại: $e',
      );
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      NotificationHelper.showSuccess(
        title: 'Thành công',
        message: 'Email đặt lại mật khẩu đã được gửi đến $email. Vui lòng kiểm tra hộp thư của bạn.',
        duration: const Duration(seconds: 5),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      NotificationHelper.showError(
        title: 'Lỗi',
        message: 'Đã xảy ra lỗi không xác định: $e',
      );
      return false;
    }
  }
  
  // Handle Firebase Auth errors
  void _handleAuthError(FirebaseAuthException e) {
    String title;
    String message;

    switch (e.code) {
      case 'user-not-found':
        title = 'Tài khoản không tồn tại';
        message = 'Không tìm thấy tài khoản với email này. Vui lòng kiểm tra lại email hoặc đăng ký tài khoản mới.';
        break;
      case 'wrong-password':
        title = 'Mật khẩu không đúng';
        message = 'Mật khẩu bạn nhập không chính xác. Vui lòng thử lại hoặc đặt lại mật khẩu.';
        break;
      case 'email-already-in-use':
        title = 'Email đã được sử dụng';
        message = 'Email này đã được đăng ký cho tài khoản khác. Vui lòng sử dụng email khác hoặc đăng nhập.';
        break;
      case 'weak-password':
        title = 'Mật khẩu quá yếu';
        message = 'Mật khẩu phải có ít nhất 6 ký tự. Vui lòng chọn mật khẩu mạnh hơn.';
        break;
      case 'invalid-email':
        title = 'Email không hợp lệ';
        message = 'Định dạng email không đúng. Vui lòng nhập email hợp lệ.';
        break;
      case 'user-disabled':
        title = 'Tài khoản bị khóa';
        message = 'Tài khoản của bạn đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
        break;
      case 'too-many-requests':
        title = 'Quá nhiều yêu cầu';
        message = 'Bạn đã thực hiện quá nhiều yêu cầu. Vui lòng đợi một lúc rồi thử lại.';
        break;
      case 'operation-not-allowed':
        title = 'Phương thức không được phép';
        message = 'Phương thức đăng nhập này hiện không được hỗ trợ.';
        break;
      case 'invalid-credential':
        title = 'Thông tin đăng nhập không hợp lệ';
        message = 'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại thông tin.';
        break;
      case 'network-request-failed':
        title = 'Lỗi kết nối';
        message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet.';
        break;
      default:
        title = 'Lỗi xác thực';
        message = e.message ?? 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
    }

    NotificationHelper.showError(
      title: title,
      message: message,
      duration: const Duration(seconds: 5),
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
