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
      builder: (maxCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (maxCtr.vimeoOrVideoUrls.isNotEmpty)
            _bottomSheetTiles(
              title: maxCtr.maxPlayerLabels.quality,
              icon: Icons.video_settings_rounded,
              subText: '${maxCtr.vimeoPlayingVideoQuality}p',
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
            title: maxCtr.maxPlayerLabels.loopVideo,
            icon: Icons.loop_rounded,
            subText: maxCtr.isLooping
                ? maxCtr.maxPlayerLabels.optionEnabled
                : maxCtr.maxPlayerLabels.optionDisabled,
            onTap: () {
              Navigator.of(context).pop();
              maxCtr.toggleLooping();
            },
          ),
          _bottomSheetTiles(
            title: maxCtr.maxPlayerLabels.playbackSpeed,
            icon: Icons.slow_motion_video_rounded,
            subText: maxCtr.currentPaybackSpeed,
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
    final maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: maxCtr.vimeoOrVideoUrls
            .map(
              (e) => ListTile(
                title: Text('${e.quality}p'),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();

                  maxCtr.changeVideoQuality(e.quality);
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
    final maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: maxCtr.videoPlaybackSpeeds
            .map(
              (e) => ListTile(
                title: Text(e),
                onTap: () {
                  onTap != null ? onTap!() : Navigator.of(context).pop();
                  maxCtr.setVideoPlayBack(e);
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
      builder: (maxCtr) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              GetBuilder<MaxGetXVideoController>(
                tag: tag,
                id: 'video-progress',
                builder: (maxCtr) {
                  return Row(
                    children: [
                      Text(
                        maxCtr.calculateVideoDuration(maxCtr.videoPosition),
                        style: const TextStyle(color: itemColor),
                      ),
                      const Text(
                        ' / ',
                        style: durationTextStyle,
                      ),
                      Text(
                        maxCtr.calculateVideoDuration(maxCtr.videoDuration),
                        style: durationTextStyle,
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              MaterialIconButton(
                toolTipMesg: maxCtr.isFullScreen
                    ? maxCtr.maxPlayerLabels.exitFullScreen ??
                        'Exit full screen${kIsWeb ? ' (f)' : ''}'
                    : maxCtr.maxPlayerLabels.fullscreen ??
                        'Fullscreen${kIsWeb ? ' (f)' : ''}',
                color: itemColor,
                onPressed: () {
                  if (maxCtr.isOverlayVisible) {
                    if (maxCtr.isFullScreen) {
                      maxCtr.disableFullScreen(context, tag);
                    } else {
                      maxCtr.enableFullScreen(tag);
                    }
                  } else {
                    maxCtr.toggleVideoOverlay();
                  }
                },
                child: Icon(
                  maxCtr.isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                ),
              ),
            ],
          ),
          GetBuilder<MaxGetXVideoController>(
            tag: tag,
            id: 'overlay',
            builder: (maxCtr) {
              if (maxCtr.isFullScreen) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                  child: Visibility(
                    visible: maxCtr.isOverlayVisible,
                    child: MaxProgressBar(
                      tag: tag,
                      alignment: Alignment.topCenter,
                      maxProgressBarConfig: maxCtr.maxProgressBarConfig,
                    ),
                  ),
                );
              }
              return MaxProgressBar(
                tag: tag,
                alignment: Alignment.bottomCenter,
                maxProgressBarConfig: maxCtr.maxProgressBarConfig,
              );
            },
          ),
        ],
      ),
    );
  }
}
