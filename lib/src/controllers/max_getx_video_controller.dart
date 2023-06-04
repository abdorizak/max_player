// ignore_for_file: no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:max_player/max_player.dart';
import 'package:universal_html/html.dart' as _html;
import 'package:wakelock/wakelock.dart';

import '../utils/logger.dart';
import '../utils/video_apis.dart';

part 'max_base_controller.dart';
part 'max_gestures_controller.dart';
part 'max_ui_controller.dart';
part 'max_video_controller.dart';
part 'max_video_quality_controller.dart';

class MaxGetXVideoController extends _MaxGesturesController {
  ///main videoplayer controller
  VideoPlayerController? get videoCtr => _videoCtr;

  ///MaxVideoPlayer state notifier
  MaxVideoState get maxVideoState => _MaxVideoState;

  ///vimeo or general --video player type
  MaxVideoPlayerType get videoPlayerType => _videoPlayerType;

  String get currentPaybackSpeed => _currentPaybackSpeed;

  ///
  Duration get videoDuration => _videoDuration;

  ///
  Duration get videoPosition => _videoPosition;

  bool controllerInitialized = false;
  late MaxPlayerConfig maxPlayerConfig;
  late PlayVideoFrom playVideoFrom;
  void config({
    required PlayVideoFrom playVideoFrom,
    required MaxPlayerConfig playerConfig,
  }) {
    this.playVideoFrom = playVideoFrom;
    _videoPlayerType = playVideoFrom.playerType;
    maxPlayerConfig = playerConfig;
    autoPlay = playerConfig.autoPlay;
    isLooping = playerConfig.isLooping;
  }

  ///*init
  Future<void> videoInit() async {
    ///
    // checkPlayerType();
    maxLog(_videoPlayerType.toString());
    try {
      await _initializePlayer();
      await _videoCtr?.initialize();
      _videoDuration = _videoCtr?.value.duration ?? Duration.zero;
      await setLooping(isLooping);
      _videoCtr?.addListener(videoListner);
      addListenerId('MaxVideoState', maxStateListner);

      checkAutoPlayVideo();
      controllerInitialized = true;
      update();

      update(['update-all']);
      // ignore: unawaited_futures
      Future.delayed(const Duration(milliseconds: 600))
          .then((value) => _isWebAutoPlayDone = true);
    } catch (e) {
      MaxVideoStateChanger(MaxVideoState.error);
      update(['errorState']);
      update(['update-all']);
      maxLog('ERROR ON max_player:  $e');
      rethrow;
    }
  }

  Future<void> _initializePlayer() async {
    switch (_videoPlayerType) {
      case MaxVideoPlayerType.network:

        ///
        _videoCtr = VideoPlayerController.network(
          playVideoFrom.dataSource!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = playVideoFrom.dataSource;
        break;
      case MaxVideoPlayerType.networkQualityUrls:
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: playVideoFrom.videoQualityUrls!,
        );

        ///
        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

        break;
      case MaxVideoPlayerType.youtube:
        final _urls = await getVideoQualityUrlsFromYoutube(
          playVideoFrom.dataSource!,
          playVideoFrom.live,
        );
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: _urls,
        );

        ///
        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

        break;
      case MaxVideoPlayerType.vimeo:
        await getQualityUrlsFromVimeoId(
          playVideoFrom.dataSource!,
          hash: playVideoFrom.hash,
        );
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: vimeoOrVideoUrls,
        );

        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

        break;
      case MaxVideoPlayerType.asset:

        ///
        _videoCtr = VideoPlayerController.asset(
          playVideoFrom.dataSource!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          package: playVideoFrom.package,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );
        playingVideoUrl = playVideoFrom.dataSource;

        break;
      case MaxVideoPlayerType.file:
        if (kIsWeb) {
          throw Exception('file doesnt support web');
        }

        ///
        _videoCtr = VideoPlayerController.file(
          playVideoFrom.file!,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
        );

        break;
      case MaxVideoPlayerType.vimeoPrivateVideos:
        await getQualityUrlsFromVimeoPrivateId(
          playVideoFrom.dataSource!,
          playVideoFrom.httpHeaders,
        );
        final _url = await getUrlFromVideoQualityUrls(
          qualityList: maxPlayerConfig.videoQualityPriority,
          videoUrls: vimeoOrVideoUrls,
        );

        _videoCtr = VideoPlayerController.network(
          _url,
          closedCaptionFile: playVideoFrom.closedCaptionFile,
          formatHint: playVideoFrom.formatHint,
          videoPlayerOptions: playVideoFrom.videoPlayerOptions,
          httpHeaders: playVideoFrom.httpHeaders,
        );
        playingVideoUrl = _url;

        break;
    }
  }

  ///Listning on keyboard events
  void onKeyBoardEvents({
    required RawKeyEvent event,
    required BuildContext appContext,
    required String tag,
  }) {
    if (kIsWeb) {
      if (event.isKeyPressed(LogicalKeyboardKey.space)) {
        togglePlayPauseVideo();
        return;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.keyM)) {
        toggleMute();
        return;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
        onLeftDoubleTap();
        return;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
        onRightDoubleTap();
        return;
      }
      if (event.isKeyPressed(LogicalKeyboardKey.keyF) &&
          event.logicalKey.keyLabel == 'F') {
        toggleFullScreenOnWeb(appContext, tag);
      }
      if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
        if (isFullScreen) {
          _html.document.exitFullscreen();
          if (!isWebPopupOverlayOpen) {
            disableFullScreen(appContext, tag);
          }
        }
      }

      return;
    }
  }

  void toggleFullScreenOnWeb(BuildContext context, String tag) {
    if (isFullScreen) {
      _html.document.exitFullscreen();
      if (!isWebPopupOverlayOpen) {
        disableFullScreen(context, tag);
      }
    } else {
      _html.document.documentElement?.requestFullscreen();
      enableFullScreen(tag);
    }
  }

  ///this func will listne to update id `_MaxVideoState`
  void maxStateListner() {
    maxLog(_MaxVideoState.toString());
    switch (_MaxVideoState) {
      case MaxVideoState.playing:
        if (maxPlayerConfig.wakelockEnabled) Wakelock.enable();
        playVideo(true);
        break;
      case MaxVideoState.paused:
        if (maxPlayerConfig.wakelockEnabled) Wakelock.disable();
        playVideo(false);
        break;
      case MaxVideoState.loading:
        isShowOverlay(true);
        break;
      case MaxVideoState.error:
        if (maxPlayerConfig.wakelockEnabled) Wakelock.disable();
        playVideo(false);
        break;
    }
  }

  ///checkes wether video should be `autoplayed` initially
  void checkAutoPlayVideo() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (autoPlay && (isVideoUiBinded ?? false)) {
        if (kIsWeb) await _videoCtr?.setVolume(0);
        MaxVideoStateChanger(MaxVideoState.playing);
      } else {
        MaxVideoStateChanger(MaxVideoState.paused);
      }
    });
  }

  Future<void> changeVideo({
    required PlayVideoFrom playVideoFrom,
    required MaxPlayerConfig playerConfig,
  }) async {
    _videoCtr?.removeListener(videoListner);
    MaxVideoStateChanger(MaxVideoState.paused);
    MaxVideoStateChanger(MaxVideoState.loading);
    keyboardFocusWeb?.removeListener(keyboadListner);
    removeListenerId('MaxVideoState', maxStateListner);
    _isWebAutoPlayDone = false;
    vimeoOrVideoUrls = [];
    config(playVideoFrom: playVideoFrom, playerConfig: playerConfig);
    keyboardFocusWeb?.requestFocus();
    keyboardFocusWeb?.addListener(keyboadListner);
    await videoInit();
  }
}
