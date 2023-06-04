// ignore_for_file: no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as _html;

import '../max_player.dart';
import 'controllers/max_getx_video_controller.dart';
import 'utils/logger.dart';
import 'widgets/double_tap_icon.dart';
import 'widgets/material_icon_button.dart';

part 'widgets/animated_play_pause_icon.dart';

part 'widgets/core/overlays/mobile_bottomsheet.dart';

part 'widgets/core/overlays/mobile_overlay.dart';

part 'widgets/core/overlays/overlays.dart';

part 'widgets/core/overlays/web_dropdown_menu.dart';

part 'widgets/core/overlays/web_overlay.dart';

part 'widgets/core/max_core_player.dart';

part 'widgets/core/video_gesture_detector.dart';

part 'widgets/full_screen_view.dart';

class MaxVideoPlayer extends StatefulWidget {
  final MaxPlayerController controller;
  final double frameAspectRatio;
  final double videoAspectRatio;
  final bool alwaysShowProgressBar;
  final bool matchVideoAspectRatioToFrame;
  final bool matchFrameAspectRatioToVideo;
  final MaxProgressBarConfig maxProgressBarConfig;
  final MaxPlayerLabels maxPlayerLabels;
  final Widget Function(OverLayOptions options)? overlayBuilder;
  final Widget Function()? onVideoError;
  final Widget? videoTitle;
  final Color? backgroundColor;
  final DecorationImage? videoThumbnail;

  /// Optional callback, fired when full screen mode toggles.
  ///
  /// Important: If this method is set, the configuration of [DeviceOrientation]
  /// and [SystemUiMode] is up to you.
  final Future<void> Function(bool isFullScreen)? onToggleFullScreen;

  /// Sets a custom loading widget.
  /// If no widget is informed, a default [CircularProgressIndicator] will be shown.
  final WidgetBuilder? onLoading;

  MaxVideoPlayer({
    Key? key,
    required this.controller,
    this.frameAspectRatio = 16 / 9,
    this.videoAspectRatio = 16 / 9,
    this.alwaysShowProgressBar = true,
    this.maxProgressBarConfig = const MaxProgressBarConfig(),
    this.maxPlayerLabels = const MaxPlayerLabels(),
    this.overlayBuilder,
    this.videoTitle,
    this.matchVideoAspectRatioToFrame = false,
    this.matchFrameAspectRatioToVideo = false,
    this.onVideoError,
    this.backgroundColor,
    this.videoThumbnail,
    this.onToggleFullScreen,
    this.onLoading,
  }) : super(key: key) {
    addToUiController();
  }

  static bool enableLogs = false;
  static bool enableGetxLogs = false;

  void addToUiController() {
    Get.find<MaxGetXVideoController>(tag: controller.getTag)

      ///add to ui controller
      ..maxPlayerLabels = maxPlayerLabels
      ..alwaysShowProgressBar = alwaysShowProgressBar
      ..maxProgressBarConfig = maxProgressBarConfig
      ..overlayBuilder = overlayBuilder
      ..videoTitle = videoTitle
      ..onToggleFullScreen = onToggleFullScreen
      ..onLoading = onLoading
      ..videoThumbnail = videoThumbnail;
  }

  @override
  State<MaxVideoPlayer> createState() => _MaxVideoPlayerState();
}

class _MaxVideoPlayerState extends State<MaxVideoPlayer>
    with TickerProviderStateMixin {
  late MaxGetXVideoController _maxCtr;

  // late String tag;
  @override
  void initState() {
    super.initState();
    // tag = widget.controller?.tag ?? UniqueKey().toString();
    _maxCtr = Get.put(
      MaxGetXVideoController(),
      permanent: true,
      tag: widget.controller.getTag,
    )..isVideoUiBinded = true;
    if (_maxCtr.wasVideoPlayingOnUiDispose ?? false) {
      _maxCtr.maxVideoStateChanger(MaxVideoState.playing, updateUi: false);
    }
    if (kIsWeb) {
      if (widget.controller.maxPlayerConfig.forcedVideoFocus) {
        _maxCtr.keyboardFocusWeb = FocusNode();
        _maxCtr.keyboardFocusWeb?.addListener(_maxCtr.keyboadListner);
      }
      //to disable mouse right click
      _html.document.onContextMenu.listen((event) => event.preventDefault());
    }
  }

  @override
  void dispose() {
    super.dispose();

    ///Checking if the video was playing when this widget is disposed
    if (_maxCtr.isvideoPlaying) {
      _maxCtr.wasVideoPlayingOnUiDispose = true;
    } else {
      _maxCtr.wasVideoPlayingOnUiDispose = false;
    }
    _maxCtr
      ..isVideoUiBinded = false
      ..maxVideoStateChanger(MaxVideoState.paused, updateUi: false);
    if (kIsWeb) {
      _maxCtr.keyboardFocusWeb?.removeListener(_maxCtr.keyboadListner);
    }
    // _maxCtr.keyboardFocus?.unfocus();
    // _maxCtr.keyboardFocusOnFullScreen?.unfocus();
    _maxCtr.hoverOverlayTimer?.cancel();
    _maxCtr.showOverlayTimer?.cancel();
    _maxCtr.showOverlayTimer1?.cancel();
    _maxCtr.leftDoubleTapTimer?.cancel();
    _maxCtr.rightDoubleTapTimer?.cancel();
    maxLog('local MaxVideoPlayer disposed');
  }

  ///
  double _frameAspectRatio = 16 / 9;

  @override
  Widget build(BuildContext context) {
    final circularProgressIndicator = _thumbnailAndLoadingWidget();
    _maxCtr.mainContext = context;

    final _videoErrorWidget = AspectRatio(
      aspectRatio: _frameAspectRatio,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: Colors.yellow,
              size: 32,
            ),
            const SizedBox(height: 20),
            Text(
              widget.maxPlayerLabels.error,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
    return GetBuilder<MaxGetXVideoController>(
      tag: widget.controller.getTag,
      builder: (_) {
        _frameAspectRatio = widget.matchFrameAspectRatioToVideo
            ? _maxCtr.videoCtr?.value.aspectRatio ?? widget.frameAspectRatio
            : widget.frameAspectRatio;
        return Center(
          child: ColoredBox(
            color: widget.backgroundColor ?? Colors.black,
            child: GetBuilder<MaxGetXVideoController>(
              tag: widget.controller.getTag,
              id: 'errorState',
              builder: (_maxCtr) {
                /// Check if has any error
                if (_maxCtr.maxVideoState == MaxVideoState.error) {
                  return widget.onVideoError?.call() ?? _videoErrorWidget;
                }

                return AspectRatio(
                  aspectRatio: _frameAspectRatio,
                  child: _maxCtr.videoCtr?.value.isInitialized ?? false
                      ? _buildPlayer()
                      : Center(child: circularProgressIndicator),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return widget.onLoading?.call(context) ??
        const CircularProgressIndicator(
          backgroundColor: Colors.black87,
          color: Colors.white,
          strokeWidth: 2,
        );
  }

  Widget _thumbnailAndLoadingWidget() {
    if (widget.videoThumbnail == null) {
      return _buildLoading();
    }

    return SizedBox.expand(
      child: TweenAnimationBuilder<double>(
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: child,
        ),
        tween: Tween<double>(begin: 0.2, end: 0.7),
        duration: const Duration(milliseconds: 400),
        child: DecoratedBox(
          decoration: BoxDecoration(image: widget.videoThumbnail),
          child: Center(
            child: _buildLoading(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final _videoAspectRatio = widget.matchVideoAspectRatioToFrame
        ? _maxCtr.videoCtr?.value.aspectRatio ?? widget.videoAspectRatio
        : widget.videoAspectRatio;
    if (kIsWeb) {
      return GetBuilder<MaxGetXVideoController>(
        tag: widget.controller.getTag,
        id: 'full-screen',
        builder: (_maxCtr) {
          if (_maxCtr.isFullScreen) return _thumbnailAndLoadingWidget();
          return _MaxCoreVideoPlayer(
            videoPlayerCtr: _maxCtr.videoCtr!,
            videoAspectRatio: _videoAspectRatio,
            tag: widget.controller.getTag,
          );
        },
      );
    } else {
      return _MaxCoreVideoPlayer(
        videoPlayerCtr: _maxCtr.videoCtr!,
        videoAspectRatio: _videoAspectRatio,
        tag: widget.controller.getTag,
      );
    }
  }
}
