part of 'max_getx_video_controller.dart';

class _MaxUiController extends _MaxBaseController {
  bool alwaysShowProgressBar = true;
  MaxProgressBarConfig maxProgressBarConfig = const MaxProgressBarConfig();
  Widget Function(OverLayOptions options)? overlayBuilder;
  Widget? videoTitle;
  DecorationImage? videoThumbnail;

  /// Callback when fullscreen mode changes
  Future<void> Function(bool isFullScreen)? onToggleFullScreen;

  /// Builder for custom loading widget
  WidgetBuilder? onLoading;

  ///video player labels
  MaxPlayerLabels maxPlayerLabels = const MaxPlayerLabels();
}
