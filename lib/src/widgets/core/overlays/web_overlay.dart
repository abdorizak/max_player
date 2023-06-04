// ignore_for_file: no_leading_underscores_for_local_identifiers

part of 'package:max_player/src/max_player.dart';

class _WebOverlay extends StatelessWidget {
  final String tag;
  const _WebOverlay({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const overlayColor = Colors.black38;
    final maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return Stack(
      children: [
        Positioned.fill(
          child: _VideoGestureDetector(
            tag: tag,
            onTap: maxCtr.togglePlayPauseVideo,
            onDoubleTap: () => maxCtr.toggleFullScreenOnWeb(context, tag),
            child: const ColoredBox(
              color: overlayColor,
              child: SizedBox.expand(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _WebOverlayBottomControlles(
            tag: tag,
          ),
        ),
        Positioned.fill(
          child: GetBuilder<MaxGetXVideoController>(
            tag: tag,
            id: 'double-tap',
            builder: (maxCtr) {
              return Row(
                children: [
                  Expanded(
                    child: IgnorePointer(
                      child: DoubleTapIcon(
                        onDoubleTap: () {},
                        tag: tag,
                        isForward: false,
                        iconOnly: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: IgnorePointer(
                      child: DoubleTapIcon(
                        onDoubleTap: () {},
                        tag: tag,
                        isForward: true,
                        iconOnly: true,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        IgnorePointer(child: maxCtr.videoTitle ?? const SizedBox()),
      ],
    );
  }
}

class _WebOverlayBottomControlles extends StatelessWidget {
  final String tag;

  const _WebOverlayBottomControlles({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return MouseRegion(
      onHover: (event) => maxCtr.onOverlayHover(),
      onExit: (event) => maxCtr.onOverlayHoverExit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaxProgressBar(
              tag: tag,
              maxProgressBarConfig: maxCtr.maxProgressBarConfig,
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        _AnimatedPlayPauseIcon(tag: tag),
                        GetBuilder<MaxGetXVideoController>(
                          tag: tag,
                          id: 'volume',
                          builder: (maxCtr) => MaterialIconButton(
                            toolTipMesg: maxCtr.isMute
                                ? maxCtr.maxPlayerLabels.unmute ??
                                    'Unmute${kIsWeb ? ' (m)' : ''}'
                                : maxCtr.maxPlayerLabels.mute ??
                                    'Mute${kIsWeb ? ' (m)' : ''}',
                            color: itemColor,
                            onPressed: maxCtr.toggleMute,
                            child: Icon(
                              maxCtr.isMute
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                            ),
                          ),
                        ),
                        GetBuilder<MaxGetXVideoController>(
                          tag: tag,
                          id: 'video-progress',
                          builder: (maxCtr) {
                            return Row(
                              children: [
                                Text(
                                  maxCtr.calculateVideoDuration(
                                    maxCtr.videoPosition,
                                  ),
                                  style: durationTextStyle,
                                ),
                                const Text(
                                  ' / ',
                                  style: durationTextStyle,
                                ),
                                Text(
                                  maxCtr.calculateVideoDuration(
                                    maxCtr.videoDuration,
                                  ),
                                  style: durationTextStyle,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        _WebSettingsDropdown(tag: tag),
                        MaterialIconButton(
                          toolTipMesg: maxCtr.isFullScreen
                              ? maxCtr.maxPlayerLabels.exitFullScreen ??
                                  'Exit full screen${kIsWeb ? ' (f)' : ''}'
                              : maxCtr.maxPlayerLabels.fullscreen ??
                                  'Fullscreen${kIsWeb ? ' (f)' : ''}',
                          color: itemColor,
                          onPressed: () => _onFullScreenToggle(maxCtr, context),
                          child: Icon(
                            maxCtr.isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onFullScreenToggle(
    MaxGetXVideoController maxCtr,
    BuildContext context,
  ) {
    if (maxCtr.isOverlayVisible) {
      if (maxCtr.isFullScreen) {
        if (kIsWeb) {
          _html.document.exitFullscreen();
          maxCtr.disableFullScreen(context, tag);
          return;
        } else {
          maxCtr.disableFullScreen(context, tag);
        }
      } else {
        if (kIsWeb) {
          _html.document.documentElement?.requestFullscreen();
          maxCtr.enableFullScreen(tag);
          return;
        } else {
          maxCtr.enableFullScreen(tag);
        }
      }
    } else {
      maxCtr.toggleVideoOverlay();
    }
  }
}
