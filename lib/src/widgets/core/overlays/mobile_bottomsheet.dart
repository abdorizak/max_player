part of 'package:max_player/src/max_player.dart';

class _MobileBottomSheet extends StatelessWidget {
  final String tag;

  const _MobileBottomSheet({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaxGetXVideoController>(
      tag: tag,
      builder: (_maxCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_maxCtr.vimeoOrVideoUrls.isNotEmpty)
            _bottomSheetTiles(
              title: _maxCtr.maxPlayerLabels.quality,
              icon: Icons.video_settings_rounded,
              subText: '${_maxCtr.vimeoPlayingVideoQuality}p',
              onTap: () {
                Navigator.of(context).pop();
                Timer(const Duration(milliseconds: 100), () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: _VideoQualitySelectorMob(
                        tag: tag,
                        onTap: null,
                      ),
                    ),
                  );
                });
                // await Future.delayed(
                //   const Duration(milliseconds: 100),
                // );
              },
            ),
          _bottomSheetTiles(
            title: _maxCtr.maxPlayerLabels.loopVideo,
            icon: Icons.loop_rounded,
            subText: _maxCtr.isLooping
                ? _maxCtr.maxPlayerLabels.optionEnabled
                : _maxCtr.maxPlayerLabels.optionDisabled,
            onTap: () {
              Navigator.of(context).pop();
              _maxCtr.toggleLooping();
            },
          ),
          _bottomSheetTiles(
            title: _maxCtr.maxPlayerLabels.playbackSpeed,
            icon: Icons.slow_motion_video_rounded,
            subText: _maxCtr.currentPaybackSpeed,
            onTap: () {
              Navigator.of(context).pop();
              Timer(const Duration(milliseconds: 100), () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => SafeArea(
                    child: _VideoPlaybackSelectorMob(
                      tag: tag,
                      onTap: null,
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  ListTile _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
    void Function()? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTap,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Text(
              title,
            ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              const SizedBox(
                height: 4,
                width: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (subText != null) const SizedBox(width: 6),
            if (subText != null)
              Text(
                subText,
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

class _VideoQualitySelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final String tag;

  const _VideoQualitySelectorMob({
    Key? key,
    required this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _maxCtr.vimeoOrVideoUrls
            .map(
              (e) => ListTile(
                title: Text('${e.quality}p'),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();

                  _maxCtr.changeVideoQuality(e.quality);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _VideoPlaybackSelectorMob extends StatelessWidget {
  final void Function()? onTap;
  final String tag;

  const _VideoPlaybackSelectorMob({
    Key? key,
    required this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _maxCtr.videoPlaybackSpeeds
            .map(
              (e) => ListTile(
                title: Text(e),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();
                  _maxCtr.setVideoPlayBack(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MobileOverlayBottomControlles extends StatelessWidget {
  final String tag;

  const _MobileOverlayBottomControlles({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const durationTextStyle = TextStyle(color: Colors.white70);
    const itemColor = Colors.white;

    return GetBuilder<MaxGetXVideoController>(
      tag: tag,
      id: 'full-screen',
      builder: (_maxCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              GetBuilder<MaxGetXVideoController>(
                tag: tag,
                id: 'video-progress',
                builder: (_maxCtr) {
                  return Row(
                    children: [
                      Text(
                        _maxCtr.calculateVideoDuration(_maxCtr.videoPosition),
                        style: const TextStyle(color: itemColor),
                      ),
                      const Text(
                        ' / ',
                        style: durationTextStyle,
                      ),
                      Text(
                        _maxCtr.calculateVideoDuration(_maxCtr.videoDuration),
                        style: durationTextStyle,
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              MaterialIconButton(
                toolTipMesg: _maxCtr.isFullScreen
                    ? _maxCtr.maxPlayerLabels.exitFullScreen ??
                        'Exit full screen${kIsWeb ? ' (f)' : ''}'
                    : _maxCtr.maxPlayerLabels.fullscreen ??
                        'Fullscreen${kIsWeb ? ' (f)' : ''}',
                color: itemColor,
                onPressed: () {
                  if (_maxCtr.isOverlayVisible) {
                    if (_maxCtr.isFullScreen) {
                      _maxCtr.disableFullScreen(context, tag);
                    } else {
                      _maxCtr.enableFullScreen(tag);
                    }
                  } else {
                    _maxCtr.toggleVideoOverlay();
                  }
                },
                child: Icon(
                  _maxCtr.isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                ),
              ),
            ],
          ),
          GetBuilder<MaxGetXVideoController>(
            tag: tag,
            id: 'overlay',
            builder: (_maxCtr) {
              if (_maxCtr.isFullScreen) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  child: Visibility(
                    visible: _maxCtr.isOverlayVisible,
                    child: MaxProgressBar(
                      tag: tag,
                      alignment: Alignment.topCenter,
                      maxProgressBarConfig: _maxCtr.maxProgressBarConfig,
                    ),
                  ),
                );
              }
              return MaxProgressBar(
                tag: tag,
                alignment: Alignment.bottomCenter,
                maxProgressBarConfig: _maxCtr.maxProgressBarConfig,
              );
            },
          ),
        ],
      ),
    );
  }
}
