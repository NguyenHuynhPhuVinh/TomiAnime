class AppUpdateModel {
  final String version;
  final String versionCode;
  final String downloadUrl;
  final String changelog;
  final bool forceUpdate;
  final DateTime releaseDate;

  AppUpdateModel({
    required this.version,
    required this.versionCode,
    required this.downloadUrl,
    required this.changelog,
    required this.forceUpdate,
    required this.releaseDate,
  });

  factory AppUpdateModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateModel(
      version: json['version'] ?? '',
      versionCode: json['version_code'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      changelog: json['changelog'] ?? '',
      forceUpdate: json['force_update'] ?? false,
      releaseDate: DateTime.tryParse(json['release_date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'version_code': versionCode,
      'download_url': downloadUrl,
      'changelog': changelog,
      'force_update': forceUpdate,
      'release_date': releaseDate.toIso8601String(),
    };
  }

  // So sánh version
  bool isNewerThan(String currentVersion) {
    try {
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final newParts = version.split('.').map(int.parse).toList();
      
      // Đảm bảo cả hai version có cùng số phần
      while (currentParts.length < 3) currentParts.add(0);
      while (newParts.length < 3) newParts.add(0);
      
      for (int i = 0; i < 3; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }
      
      return false; // Versions are equal
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }
}
