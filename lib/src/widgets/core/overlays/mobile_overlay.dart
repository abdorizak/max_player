part of 'package:max_player/src/max_player.dart';

class _MobileOverlay extends StatelessWidget {
  final String tag;

  const _MobileOverlay({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const overlayColor = Colors.black38;
    const itemColor = Colors.white;
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return Stack(
      alignment: Alignment.center,
      children: [
        _VideoGestureDetector(
          tag: tag,
          child: ColoredBox(
            color: overlayColor,
            child: Row(
              children: [
                Expanded(
                  child: DoubleTapIcon(
                    tag: tag,
                    isForward: false,
                    height: double.maxFinite,
                    onDoubleTap: _isRtl()
                        ? _maxCtr.onRightDoubleTap
                        : _maxCtr.onLeftDoubleTap,
                  ),
                ),
                SizedBox(
                  height: double.infinity,
                  child: Center(
                    child: _AnimatedPlayPauseIcon(tag: tag, size: 42),
                  ),
                ),
                Expanded(
                  child: DoubleTapIcon(
                    isForward: true,
                    tag: tag,
                    height: double.maxFinite,
                    onDoubleTap: _isRtl()
                        ? _maxCtr.onLeftDoubleTap
                        : _maxCtr.onRightDoubleTap,
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: IgnorePointer(
                  child: _maxCtr.videoTitle ?? const SizedBox(),
                ),
              ),
              MaterialIconButton(
                toolTipMesg: _maxCtr.maxPlayerLabels.settings,
                color: itemColor,
                onPressed: () {
                  if (_maxCtr.isOverlayVisible) {
                    _bottomSheet(context);
                  } else {
                    _maxCtr.toggleVideoOverlay();
                  }
                },
                child: const Icon(
                  Icons.more_vert_rounded,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _MobileOverlayBottomControlles(tag: tag),
        ),
      ],
    );
  }

  bool _isRtl() {
    final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
    final langs = [
      'ar', // Arabic
      'fa', // Farsi
      'he', // Hebrew
      'ps', // Pashto
      'ur', // Urdu
    ];
    for (int i = 0; i < langs.length; i++) {
      final lang = langs[i];
      if (locale.toString().contains(lang)) {
        return true;
      }
    }
    return false;
  }

  void _bottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(child: _MobileBottomSheet(tag: tag)),
    );
  }
}
