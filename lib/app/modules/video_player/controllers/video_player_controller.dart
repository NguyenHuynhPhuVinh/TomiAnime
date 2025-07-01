import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class VideoPlayerController extends GetxController {
  // Observable variables - removed loading state

  // Parameters từ navigation
  late String embedUrl;
  late String episodeName;
  late String animeTitle;
  late int episodeIndex;
  late int totalEpisodes;

  // WebView controller
  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();

    // Lấy parameters từ Get.arguments
    final arguments = Get.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      embedUrl = arguments['embedUrl'] ?? '';
      episodeName = arguments['episodeName'] ?? '';
      animeTitle = arguments['animeTitle'] ?? '';
      episodeIndex = arguments['episodeIndex'] ?? 0;
      totalEpisodes = arguments['totalEpisodes'] ?? 0;

      print('🎥 VideoPlayerController initialized:');
      print('   🏷️  Anime: $animeTitle');
      print('   📺 Episode: $episodeName');
      print('   🔗 Embed URL: $embedUrl');
      print('   📊 Episode ${episodeIndex + 1}/$totalEpisodes');

      // URL validation only, no loading state
      if (embedUrl.isEmpty) {
        print('⚠️ Empty embed URL');
      }
    } else {
      print('⚠️ Missing video arguments');
    }
  }

  /// Xử lý khi WebView được tạo
  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    print('🎥 WebView created for episode: $episodeName');
    print('🔗 Embed URL: $embedUrl');
    print('📱 Loading in video player screen...');
  }

  /// Xử lý khi bắt đầu load
  void onLoadStart(InAppWebViewController controller, WebUri? url) {
    print('🔄 Loading embed URL: $url');
  }

  /// Xử lý khi load xong
  void onLoadStop(InAppWebViewController controller, WebUri? url) {
    print('✅ Embed URL loaded: $url');
  }

  /// Xử lý lỗi - không hiện popup vì video vẫn có thể phát được
  void onReceivedError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceError error,
  ) {
    // Chỉ log, không set error để tránh hiện popup
    print(
      '⚠️ WebView error (ignored): ${error.description} (Code: ${error.type})',
    );
  }

  /// Xử lý lỗi HTTP - không hiện popup vì video vẫn có thể phát được
  void onReceivedHttpError(
    InAppWebViewController controller,
    WebResourceRequest request,
    WebResourceResponse errorResponse,
  ) {
    // Chỉ log, không set error để tránh hiện popup
    print(
      '⚠️ WebView HTTP error (ignored): ${errorResponse.reasonPhrase} (Status: ${errorResponse.statusCode})',
    );
  }

  /// Reload video
  void reload() {
    if (webViewController != null) {
      print('🔄 Reloading embed URL: $embedUrl');
      webViewController!.reload();
    }
  }

  /// Quay lại màn hình trước
  void goBack() {
    Get.back();
  }

  /// Lấy title cho app bar
  String get appBarTitle {
    return '$animeTitle - Tập $episodeName';
  }

  /// Lấy subtitle cho app bar
  String get appBarSubtitle {
    return 'Tập ${episodeIndex + 1}/$totalEpisodes';
  }

  /// Handle fullscreen enter - auto rotate to landscape
  void onEnterFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    print('📱 Video entered fullscreen - rotated to landscape');
  }

  /// Handle fullscreen exit - auto rotate to portrait
  void onExitFullscreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    print('📱 Video exited fullscreen - rotated to portrait');
  }

  @override
  void onClose() {
    // Restore portrait orientation when controller is disposed
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    webViewController = null;
    super.onClose();
  }
}
