part of 'package:max_player/src/max_player.dart';

class _VideoOverlays extends StatelessWidget {
  final String tag;

  const _VideoOverlays({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    if (_maxCtr.overlayBuilder != null) {
      return GetBuilder<MaxGetXVideoController>(
        id: 'update-all',
        tag: tag,
        builder: (_maxCtr) {
          ///Custom overlay
          final _progressBar = MaxProgressBar(
            tag: tag,
            maxProgressBarConfig: _maxCtr.maxProgressBarConfig,
          );
          final overlayOptions = OverLayOptions(
            maxVideoState: _maxCtr.maxVideoState,
            videoDuration: _maxCtr.videoDuration,
            videoPosition: _maxCtr.videoPosition,
            isFullScreen: _maxCtr.isFullScreen,
            isLooping: _maxCtr.isLooping,
            isOverlayVisible: _maxCtr.isOverlayVisible,
            isMute: _maxCtr.isMute,
            autoPlay: _maxCtr.autoPlay,
            currentVideoPlaybackSpeed: _maxCtr.currentPaybackSpeed,
            videoPlayBackSpeeds: _maxCtr.videoPlaybackSpeeds,
            videoPlayerType: _maxCtr.videoPlayerType,
            maxProgresssBar: _progressBar,
          );

          /// Returns the custom overlay, otherwise returns the default
          /// overlay with gesture detector
          return _maxCtr.overlayBuilder!(overlayOptions);
        },
      );
    } else {
      ///Built in overlay
      return GetBuilder<MaxGetXVideoController>(
        tag: tag,
        id: 'overlay',
        builder: (_maxCtr) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _maxCtr.isOverlayVisible ? 1 : 0,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                if (!kIsWeb) _MobileOverlay(tag: tag),
                if (kIsWeb) _WebOverlay(tag: tag),
              ],
            ),
          );
        },
      );
    }
  }
}
