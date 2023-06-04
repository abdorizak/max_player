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
  late MaxGetXVideoController _maxCtr;
  @override
  void initState() {
    _maxCtr = Get.find<MaxGetXVideoController>(tag: widget.tag);
    _payCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _maxCtr.addListenerId('maxVideoState', playPauseListner);
    if (_maxCtr.isvideoPlaying) {
      if (mounted) _payCtr.forward();
    }
    super.initState();
  }

  void playPauseListner() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_maxCtr.maxVideoState == MaxVideoState.playing) {
        if (mounted) _payCtr.forward();
      }
      if (_maxCtr.maxVideoState == MaxVideoState.paused) {
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
      builder: (_maxCtr) {
        return GetBuilder<MaxGetXVideoController>(
          tag: widget.tag,
          id: 'maxVideoState',
          builder: (_f) => MaterialIconButton(
            toolTipMesg: _f.isvideoPlaying
                ? _maxCtr.maxPlayerLabels.pause ??
                    'Pause${kIsWeb ? ' (space)' : ''}'
                : _maxCtr.maxPlayerLabels.play ??
                    'Play${kIsWeb ? ' (space)' : ''}',
            onPressed:
                _maxCtr.isOverlayVisible ? _maxCtr.togglePlayPauseVideo : null,
            child: onStateChange(_maxCtr),
          ),
        );
      },
    );
  }

  Widget onStateChange(MaxGetXVideoController _maxCtr) {
    if (kIsWeb) return _playPause(_maxCtr);
    if (_maxCtr.maxVideoState == MaxVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(_maxCtr);
    }
  }

  Widget _playPause(MaxGetXVideoController _maxCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _payCtr,
      color: Colors.white,
      size: widget.size,
    );
  }
}
