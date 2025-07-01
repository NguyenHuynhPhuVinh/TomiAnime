# Hướng dẫn thiết lập Firestore Security Rules

## Bước 1: Bật Firestore trong Firebase Console

1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn dự án TomiAnime
3. Vào **Firestore Database**
4. Click **Create database**
5. Chọn **Start in test mode** (tạm thời)
6. Chọn location gần nhất (asia-southeast1)

## Bước 2: Cấu hình Security Rules

Vào **Firestore Database** → **Rules** và thay thế bằng rules sau:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - chỉ user đó mới được đọc/ghi data của mình
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Anime watch status subcollection - chỉ user đó mới được đọc/ghi
      match /animeWatchStatus/{animeId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Các collection khác (anime, cards, etc.) - chỉ user đã đăng nhập mới được đọc
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if false; // Tạm thời không cho phép ghi
    }
  }
}
```

## Bước 3: Test Rules

Sau khi thiết lập rules:

1. **Test đăng nhập** - Thử đăng nhập/đăng ký
2. **Kiểm tra Firestore** - Vào Firestore Console xem có data user không
3. **Test bảo mật** - Thử truy cập data của user khác (phải bị từ chối)

## Bước 4: Kiểm tra dữ liệu

Trong Firestore Console, bạn sẽ thấy:

```
📁 users
  📄 [user-uid-1]
    - uid: "user-uid-1"
    - email: "user@example.com"
    - displayName: "Tên người dùng"
    - createdAt: timestamp
    📁 animeWatchStatus
      📄 [mal-id-1]
        - malId: 123
        - title: "Tên anime"
        - titleEnglish: "English title"
        - type: "TV"
        - totalEpisodes: 12
        - score: 8.5
        - genres: ["Action", "Adventure"]
        - images: {...}
        - status: "watching" // saved, watching, completed
        - currentEpisode: 5
        - watchedEpisodes: [0, 1, 2, 3, 4, 5]
        - lastWatchedAt: timestamp
        - savedAt: timestamp
      📄 [mal-id-2]
        - malId: 456
        - title: "Tên anime khác"
        - status: "completed"
        - watchedEpisodes: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
        - ...
  📄 [user-uid-2]
    - uid: "user-uid-2"
    - email: "user2@example.com"
    - displayName: "Tên người dùng 2"
    - createdAt: timestamp
    📁 animeWatchStatus
      📄 [mal-id-3]
        - status: "saved"
        - watchedEpisodes: []
        - ...
```

## Lưu ý quan trọng

- **Test mode** chỉ hoạt động 30 ngày
- Sau đó phải chuyển sang **Production mode** với rules bảo mật
- Rules hiện tại chỉ cho phép user đọc/ghi data của chính mình
- Cần cập nhật rules khi thêm tính năng mới
- **Không cần tạo index** - App đã được tối ưu để tránh compound queries

## Performance Optimization

### Tránh Compound Index

App đã được tối ưu để tránh cần tạo compound index:

- Lấy tất cả documents trong collection trước
- Filter và sort trong memory (client-side)
- Phù hợp cho số lượng anime không quá lớn (< 1000 items)

### Caching Strategy

- Firestore tự động cache documents đã tải
- Offline support được bật mặc định
- Data sẽ sync khi có kết nối internet

## Troubleshooting

### Lỗi "Permission denied"

- Kiểm tra user đã đăng nhập chưa
- Kiểm tra rules có đúng không
- Kiểm tra user có quyền truy cập document đó không

### Lỗi "Document not found"

- Kiểm tra user đã được lưu vào Firestore chưa
- Kiểm tra UID có đúng không
- Xem log trong console để debug

### Lỗi "Query requires an index"

- App đã được tối ưu để tránh lỗi này
- Nếu vẫn gặp, kiểm tra lại query trong code
- Đảm bảo không sử dụng compound queries với orderBy
