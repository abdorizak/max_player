part of 'package:max_player/src/max_player.dart';

class _AnimatedPlayPauseIcon extends StatefulWidget {
  final double? size;
  final String tag;

  const _AnimatedPlayPauseIcon({
    Key? key,
    this.size,
    required this.tag,
  }) : super(key: key);

  @override
  State<_AnimatedPlayPauseIcon> createState() => _AnimatedPlayPauseIconState();
}

class _AnimatedPlayPauseIconState extends State<_AnimatedPlayPauseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _payCtr;
  late MaxGetXVideoController maxCtr;
  @override
  void initState() {
    maxCtr = Get.find<MaxGetXVideoController>(tag: widget.tag);
    _payCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    maxCtr.addListenerId('MaxVideoState', playPauseListner);
    if (maxCtr.isvideoPlaying) {
      if (mounted) _payCtr.forward();
    }
    super.initState();
  }

  void playPauseListner() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (maxCtr.maxVideoState == MaxVideoState.playing) {
        if (mounted) _payCtr.forward();
      }
      if (maxCtr.maxVideoState == MaxVideoState.paused) {
        if (mounted) _payCtr.reverse();
      }
    });
  }

  @override
  void dispose() {
    // maxLog('Play-pause-controller-disposed');
    _payCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaxGetXVideoController>(
      tag: widget.tag,
      id: 'overlay',
      builder: (maxCtr) {
        return GetBuilder<MaxGetXVideoController>(
          tag: widget.tag,
          id: 'MaxVideoState',
          builder: (f) => MaterialIconButton(
            toolTipMesg: f.isvideoPlaying
                ? maxCtr.maxPlayerLabels.pause ??
                    'Pause${kIsWeb ? ' (space)' : ''}'
                : maxCtr.maxPlayerLabels.play ??
                    'Play${kIsWeb ? ' (space)' : ''}',
            onPressed:
                maxCtr.isOverlayVisible ? maxCtr.togglePlayPauseVideo : null,
            child: onStateChange(maxCtr),
          ),
        );
      },
    );
  }

  Widget onStateChange(MaxGetXVideoController maxCtr) {
    if (kIsWeb) return _playPause(maxCtr);
    if (maxCtr.maxVideoState == MaxVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(maxCtr);
    }
  }

  Widget _playPause(MaxGetXVideoController maxCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _payCtr,
      color: Colors.white,
      size: widget.size,
    );
  }
}
