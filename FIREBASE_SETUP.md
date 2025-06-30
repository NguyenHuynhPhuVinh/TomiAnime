# Hướng dẫn cài đặt Firebase cho TomiAnime

## 1. Tạo dự án Firebase

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo dự án mới hoặc chọn dự án hiện có
3. Bật Authentication và chọn phương thức đăng nhập:
   - Email/Password
   - Google Sign-In

## 2. Cấu hình Firebase cho Flutter

### Cài đặt Firebase CLI
```bash
npm install -g firebase-tools
```

### Đăng nhập Firebase
```bash
firebase login
```

### Cài đặt FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Cấu hình Firebase cho dự án
```bash
flutterfire configure
```

Lệnh này sẽ:
- Tạo file `firebase_options.dart` với cấu hình chính xác
- Cấu hình Firebase cho Android và iOS
- Tự động thêm các file cấu hình cần thiết

## 3. Cấu hình Google Sign-In

### Android
1. Trong Firebase Console, vào Project Settings
2. Tải file `google-services.json`
3. Đặt file vào `android/app/`
4. Thêm vào `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

5. Thêm vào `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

### iOS
1. Tải file `GoogleService-Info.plist`
2. Thêm vào dự án iOS trong Xcode
3. Cấu hình URL Scheme trong `ios/Runner/Info.plist`

## 4. Cập nhật file firebase_options.dart

Sau khi chạy `flutterfire configure`, file `lib/firebase_options.dart` sẽ được tạo tự động với cấu hình chính xác.

## 5. Test Authentication

Sau khi cấu hình xong, bạn có thể:
1. Chạy ứng dụng
2. Thử đăng ký tài khoản mới
3. Thử đăng nhập với email/password
4. Thử đăng nhập với Google

## Lưu ý quan trọng

- File `firebase_options.dart` hiện tại chỉ là mẫu
- Bạn cần chạy `flutterfire configure` để có cấu hình chính xác
- Đảm bảo bật Authentication trong Firebase Console
- Cấu hình Google Sign-In trong Firebase Console nếu muốn sử dụng

## Troubleshooting

### Lỗi "No Firebase App"
- Đảm bảo đã chạy `Firebase.initializeApp()` trong main.dart
- Kiểm tra file firebase_options.dart có đúng cấu hình

### Lỗi Google Sign-In
- Kiểm tra SHA-1 fingerprint trong Firebase Console
- Đảm bảo package name khớp với Firebase project

### Lỗi iOS
- Kiểm tra Bundle ID khớp với Firebase project
- Đảm bảo đã thêm GoogleService-Info.plist vào Xcode project
