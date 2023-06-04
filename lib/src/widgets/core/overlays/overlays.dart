// ignore_for_file: no_leading_underscores_for_local_identifiers

part of 'package:max_player/src/max_player.dart';

class _VideoOverlays extends StatelessWidget {
  final String tag;

  const _VideoOverlays({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    if (maxCtr.overlayBuilder != null) {
      return GetBuilder<MaxGetXVideoController>(
        id: 'update-all',
        tag: tag,
        builder: (maxCtr) {
          ///Custom overlay
          final _progressBar = MaxProgressBar(
            tag: tag,
            maxProgressBarConfig: maxCtr.maxProgressBarConfig,
          );
          final overlayOptions = OverLayOptions(
            maxVideoState: maxCtr.maxVideoState,
            videoDuration: maxCtr.videoDuration,
            videoPosition: maxCtr.videoPosition,
            isFullScreen: maxCtr.isFullScreen,
            isLooping: maxCtr.isLooping,
            isOverlayVisible: maxCtr.isOverlayVisible,
            isMute: maxCtr.isMute,
            autoPlay: maxCtr.autoPlay,
            currentVideoPlaybackSpeed: maxCtr.currentPaybackSpeed,
            videoPlayBackSpeeds: maxCtr.videoPlaybackSpeeds,
            videoPlayerType: maxCtr.videoPlayerType,
            maxProgresssBar: _progressBar,
          );

          /// Returns the custom overlay, otherwise returns the default
          /// overlay with gesture detector
          return maxCtr.overlayBuilder!(overlayOptions);
        },
      );
    } else {
      ///Built in overlay
      return GetBuilder<MaxGetXVideoController>(
        tag: tag,
        id: 'overlay',
        builder: (maxCtr) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: maxCtr.isOverlayVisible ? 1 : 0,
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
