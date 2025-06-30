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

## 3. Lấy SHA-1 Certificate Fingerprint (Quan trọng cho Google Sign-In)

### Bước 1: Thiết lập JAVA_HOME (nếu chưa có)

**PowerShell:**

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-24"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
```

**Command Prompt:**

```cmd
set JAVA_HOME=C:\Program Files\Java\jdk-24
set PATH=%JAVA_HOME%\bin;%PATH%
```

### Bước 2: Lấy SHA-1 Fingerprint

**Cách 1: Sử dụng Gradle (Khuyên dùng)**

```bash
cd android
gradlew.bat signingReport
```

**Cách 2: Sử dụng keytool**

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Bước 3: Tìm SHA-1 trong output

Tìm dòng có **SHA1:** trong phần **debug**, ví dụ:

```
Variant: debug
Config: debug
Store: C:\Users\[username]\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: 78:E1:34:28:27:7F:22:0C:23:B2:46:1E:20:89:3D:A9:74:CC:CF:B1
```

**Copy SHA-1:** `78:E1:34:28:27:7F:22:0C:23:B2:46:1E:20:89:3D:A9:74:CC:CF:B1`

## 4. Cấu hình Google Sign-In

### Android

1. Trong Firebase Console, vào Project Settings
2. Scroll xuống phần **Your apps**
3. Click vào app Android hoặc **Add app** → Android
4. Điền thông tin:
   - **Android package name**: `com.tomisakae.anime`
   - **App nickname**: TomiAnime
   - **Debug signing certificate SHA-1**: Paste SHA-1 vừa lấy được
5. Click **Register app**
6. **Tải file `google-services.json`**
7. **Đặt file vào `android/app/`**
8. Click **Next** → **Next** → **Continue to console**

### Thêm SHA-1 vào app đã tạo

1. Vào **Project Settings** → **Your apps**
2. Click vào app Android
3. Click **Add fingerprint**
4. Paste SHA-1 và Save

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

### Lỗi Google Sign-In (ApiException: 10)

**Nguyên nhân chính**: Chưa thêm SHA-1 fingerprint vào Firebase Console

**Cách khắc phục**:

1. Lấy SHA-1 theo hướng dẫn ở **Bước 3**
2. Thêm SHA-1 vào Firebase Console:
   - Vào **Project Settings** → **Your apps**
   - Click vào app Android
   - Click **Add fingerprint**
   - Paste SHA-1 và Save
3. Đảm bảo package name khớp: `com.tomisakae.anime`
4. Clean và rebuild: `flutter clean && flutter run`

### Lỗi JAVA_HOME

**Lỗi**: `JAVA_HOME is not set and no 'java' command could be found`

**Cách khắc phục**: Thiết lập JAVA_HOME theo hướng dẫn ở **Bước 1**

### Lỗi iOS

- Kiểm tra Bundle ID khớp với Firebase project
- Đảm bảo đã thêm GoogleService-Info.plist vào Xcode project
