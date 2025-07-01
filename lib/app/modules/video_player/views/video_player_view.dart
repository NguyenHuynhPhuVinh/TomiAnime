import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../controllers/video_player_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class VideoPlayerView extends GetView<VideoPlayerController> {
  const VideoPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Iconsax.arrow_left, color: Colors.white),
        onPressed: () => controller.goBack(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.appBarTitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            controller.appBarSubtitle,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Iconsax.refresh, color: Colors.white),
          onPressed: () => controller.reload(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        // WebView với container cố định
        Container(
          width: double.infinity,
          height: double.infinity,
          child: _buildWebView(),
        ),

        // Loading overlay - chỉ hiện trong 3 giây đầu
        Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingOverlay();
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildWebView() {
    print('🎥 Loading embed URL directly: ${controller.embedUrl}');

    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(controller.embedUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        useHybridComposition: true,
      ),
      onWebViewCreated: (InAppWebViewController webViewController) {
        controller.onWebViewCreated(webViewController);
      },
      onLoadStart: (InAppWebViewController webViewController, WebUri? url) {
        controller.onLoadStart(webViewController, url);
      },
      onLoadStop: (InAppWebViewController webViewController, WebUri? url) {
        controller.onLoadStop(webViewController, url);
      },
      onReceivedError:
          (
            InAppWebViewController webViewController,
            WebResourceRequest request,
            WebResourceError error,
          ) {
            controller.onReceivedError(webViewController, request, error);
          },
      onReceivedHttpError:
          (
            InAppWebViewController webViewController,
            WebResourceRequest request,
            WebResourceResponse errorResponse,
          ) {
            controller.onReceivedHttpError(
              webViewController,
              request,
              errorResponse,
            );
          },
      onEnterFullscreen: (InAppWebViewController webViewController) {
        controller.onEnterFullscreen();
      },
      onExitFullscreen: (InAppWebViewController webViewController) {
        controller.onExitFullscreen();
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.animeTheme,
              strokeWidth: 3.w,
            ),
            SizedBox(height: 16.h),
            Text(
              'Đang tải video...',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }


}
