import 'package:cloud_firestore/cloud_firestore.dart';
import 'anime_model.dart';

/// Enum cho trạng thái xem anime
enum AnimeWatchStatus {
  saved, // Đã lưu (chưa xem)
  watching, // Đang xem
  completed, // Đã hoàn thành
}

/// Extension để convert enum sang string và ngược lại
extension AnimeWatchStatusExtension on AnimeWatchStatus {
  String get value {
    switch (this) {
      case AnimeWatchStatus.saved:
        return 'saved';
      case AnimeWatchStatus.watching:
        return 'watching';
      case AnimeWatchStatus.completed:
        return 'completed';
    }
  }

  String get displayName {
    switch (this) {
      case AnimeWatchStatus.saved:
        return 'Đã lưu';
      case AnimeWatchStatus.watching:
        return 'Đang xem';
      case AnimeWatchStatus.completed:
        return 'Đã hoàn thành';
    }
  }

  static AnimeWatchStatus fromString(String value) {
    switch (value) {
      case 'saved':
        return AnimeWatchStatus.saved;
      case 'watching':
        return AnimeWatchStatus.watching;
      case 'completed':
        return AnimeWatchStatus.completed;
      default:
        return AnimeWatchStatus.saved;
    }
  }
}

/// Model cho trạng thái xem anime của user
class AnimeWatchStatusModel {
  final int malId;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final String type;
  final int? totalEpisodes;
  final double? score;
  final List<String> genres;
  final Map<String, dynamic> images;

  // Trạng thái xem
  final AnimeWatchStatus status;
  final int currentEpisode; // Tập hiện tại đang xem (0-based)
  final List<int> watchedEpisodes; // Danh sách các tập đã xem (0-based)
  final DateTime lastWatchedAt; // Lần xem cuối
  final DateTime savedAt; // Lần lưu đầu tiên

  AnimeWatchStatusModel({
    required this.malId,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.type,
    this.totalEpisodes,
    this.score,
    required this.genres,
    required this.images,
    required this.status,
    this.currentEpisode = 0,
    this.watchedEpisodes = const [],
    required this.lastWatchedAt,
    required this.savedAt,
  });

  /// Tạo từ AnimeModel khi lưu lần đầu
  factory AnimeWatchStatusModel.fromAnimeModel(AnimeModel anime) {
    final now = DateTime.now();
    return AnimeWatchStatusModel(
      malId: anime.malId,
      title: anime.title,
      titleEnglish: anime.titleEnglish,
      titleJapanese: anime.titleJapanese,
      type: anime.type,
      totalEpisodes: anime.episodes,
      score: anime.score,
      genres: anime.genres,
      images: anime.images.toJson(),
      status: AnimeWatchStatus.saved,
      currentEpisode: 0,
      watchedEpisodes: [],
      lastWatchedAt: now,
      savedAt: now,
    );
  }

  /// Tạo từ Firestore document
  factory AnimeWatchStatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnimeWatchStatusModel(
      malId: data['malId'] ?? 0,
      title: data['title'] ?? '',
      titleEnglish: data['titleEnglish'],
      titleJapanese: data['titleJapanese'],
      type: data['type'] ?? '',
      totalEpisodes: data['totalEpisodes'],
      score: data['score']?.toDouble(),
      genres: List<String>.from(data['genres'] ?? []),
      images: Map<String, dynamic>.from(data['images'] ?? {}),
      status: AnimeWatchStatusExtension.fromString(data['status'] ?? 'saved'),
      currentEpisode: data['currentEpisode'] ?? 0,
      watchedEpisodes: List<int>.from(data['watchedEpisodes'] ?? []),
      lastWatchedAt:
          (data['lastWatchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      savedAt: (data['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert sang Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'malId': malId,
      'title': title,
      'titleEnglish': titleEnglish,
      'titleJapanese': titleJapanese,
      'type': type,
      'totalEpisodes': totalEpisodes,
      'score': score,
      'genres': genres,
      'images': images,
      'status': status.value,
      'currentEpisode': currentEpisode,
      'watchedEpisodes': watchedEpisodes,
      'lastWatchedAt': Timestamp.fromDate(lastWatchedAt),
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }

  /// Copy với các thay đổi
  AnimeWatchStatusModel copyWith({
    AnimeWatchStatus? status,
    int? currentEpisode,
    List<int>? watchedEpisodes,
    DateTime? lastWatchedAt,
  }) {
    return AnimeWatchStatusModel(
      malId: malId,
      title: title,
      titleEnglish: titleEnglish,
      titleJapanese: titleJapanese,
      type: type,
      totalEpisodes: totalEpisodes,
      score: score,
      genres: genres,
      images: images,
      status: status ?? this.status,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      watchedEpisodes: watchedEpisodes ?? this.watchedEpisodes,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      savedAt: savedAt,
    );
  }

  /// Kiểm tra xem tập có được xem chưa
  bool isEpisodeWatched(int episodeIndex) {
    return watchedEpisodes.contains(episodeIndex);
  }

  /// Tính phần trăm đã xem
  double get watchProgress {
    if (totalEpisodes == null || totalEpisodes! <= 0) {
      // Nếu không biết tổng số tập, trả về 0.0 để hiển thị progress không xác định
      return 0.0;
    }
    return (watchedEpisodes.length / totalEpisodes!).clamp(0.0, 1.0);
  }

  /// Kiểm tra xem đã xem hết chưa
  bool get isCompleted {
    if (totalEpisodes == null || totalEpisodes! <= 0) {
      // Nếu không biết tổng số tập, không thể xác định đã hoàn thành
      return false;
    }
    return watchedEpisodes.length >= totalEpisodes!;
  }

  /// Lấy text hiển thị progress
  String get progressText {
    if (totalEpisodes == null || totalEpisodes! <= 0) {
      return '${watchedEpisodes.length}/? tập';
    }
    return '${watchedEpisodes.length}/$totalEpisodes tập';
  }
}
