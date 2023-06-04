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
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return Stack(
      children: [
        Positioned.fill(
          child: _VideoGestureDetector(
            tag: tag,
            onTap: _maxCtr.togglePlayPauseVideo,
            onDoubleTap: () => _maxCtr.toggleFullScreenOnWeb(context, tag),
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
            builder: (_maxCtr) {
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
        IgnorePointer(child: _maxCtr.videoTitle ?? const SizedBox()),
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
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return MouseRegion(
      onHover: (event) => _maxCtr.onOverlayHover(),
      onExit: (event) => _maxCtr.onOverlayHoverExit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaxProgressBar(
              tag: tag,
              maxProgressBarConfig: _maxCtr.maxProgressBarConfig,
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
                          builder: (_maxCtr) => MaterialIconButton(
                            toolTipMesg: _maxCtr.isMute
                                ? _maxCtr.maxPlayerLabels.unmute ??
                                    'Unmute${kIsWeb ? ' (m)' : ''}'
                                : _maxCtr.maxPlayerLabels.mute ??
                                    'Mute${kIsWeb ? ' (m)' : ''}',
                            color: itemColor,
                            onPressed: _maxCtr.toggleMute,
                            child: Icon(
                              _maxCtr.isMute
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                            ),
                          ),
                        ),
                        GetBuilder<MaxGetXVideoController>(
                          tag: tag,
                          id: 'video-progress',
                          builder: (_maxCtr) {
                            return Row(
                              children: [
                                Text(
                                  _maxCtr.calculateVideoDuration(
                                    _maxCtr.videoPosition,
                                  ),
                                  style: durationTextStyle,
                                ),
                                const Text(
                                  ' / ',
                                  style: durationTextStyle,
                                ),
                                Text(
                                  _maxCtr.calculateVideoDuration(
                                    _maxCtr.videoDuration,
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
                          toolTipMesg: _maxCtr.isFullScreen
                              ? _maxCtr.maxPlayerLabels.exitFullScreen ??
                                  'Exit full screen${kIsWeb ? ' (f)' : ''}'
                              : _maxCtr.maxPlayerLabels.fullscreen ??
                                  'Fullscreen${kIsWeb ? ' (f)' : ''}',
                          color: itemColor,
                          onPressed: () =>
                              _onFullScreenToggle(_maxCtr, context),
                          child: Icon(
                            _maxCtr.isFullScreen
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
    MaxGetXVideoController _maxCtr,
    BuildContext context,
  ) {
    if (_maxCtr.isOverlayVisible) {
      if (_maxCtr.isFullScreen) {
        if (kIsWeb) {
          _html.document.exitFullscreen();
          _maxCtr.disableFullScreen(context, tag);
          return;
        } else {
          _maxCtr.disableFullScreen(context, tag);
        }
      } else {
        if (kIsWeb) {
          _html.document.documentElement?.requestFullscreen();
          _maxCtr.enableFullScreen(tag);
          return;
        } else {
          _maxCtr.enableFullScreen(tag);
        }
      }
    } else {
      _maxCtr.toggleVideoOverlay();
    }
  }
}
