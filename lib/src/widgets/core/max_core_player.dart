part of 'package:max_player/src/max_player.dart';

class _MaxCoreVideoPlayer extends StatelessWidget {
  final VideoPlayerController videoPlayerCtr;
  final double videoAspectRatio;
  final String tag;

  const _MaxCoreVideoPlayer({
    Key? key,
    required this.videoPlayerCtr,
    required this.videoAspectRatio,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return Builder(
      builder: (_ctrx) {
        return RawKeyboardListener(
          autofocus: true,
          focusNode:
              (_maxCtr.isFullScreen ? FocusNode() : _maxCtr.keyboardFocusWeb) ??
                  FocusNode(),
          onKey: (value) => _maxCtr.onKeyBoardEvents(
            event: value,
            appContext: _ctrx,
            tag: tag,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: videoAspectRatio,
                  child: VideoPlayer(videoPlayerCtr),
                ),
              ),
              GetBuilder<MaxGetXVideoController>(
                tag: tag,
                id: 'maxVideoState',
                builder: (_) => GetBuilder<MaxGetXVideoController>(
                  tag: tag,
                  id: 'video-progress',
                  builder: (_maxCtr) {
                    if (_maxCtr.videoThumbnail == null) {
                      return const SizedBox();
                    }

                    if (_maxCtr.maxVideoState == MaxVideoState.paused &&
                        _maxCtr.videoPosition == Duration.zero) {
                      return SizedBox.expand(
                        child: TweenAnimationBuilder<double>(
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: child,
                          ),
                          tween: Tween<double>(begin: 0.7, end: 1),
                          duration: const Duration(milliseconds: 400),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: _maxCtr.videoThumbnail,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              _VideoOverlays(tag: tag),
              IgnorePointer(
                child: GetBuilder<MaxGetXVideoController>(
                  tag: tag,
                  id: 'maxVideoState',
                  builder: (_maxCtr) {
                    final loadingWidget = _maxCtr.onLoading?.call(context) ??
                        const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        );

                    if (kIsWeb) {
                      switch (_maxCtr.maxVideoState) {
                        case MaxVideoState.loading:
                          return loadingWidget;
                        case MaxVideoState.paused:
                          return const Center(
                            child: Icon(
                              Icons.play_arrow,
                              size: 45,
                              color: Colors.white,
                            ),
                          );
                        case MaxVideoState.playing:
                          return Center(
                            child: TweenAnimationBuilder<double>(
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: child,
                              ),
                              tween: Tween<double>(begin: 1, end: 0),
                              duration: const Duration(seconds: 1),
                              child: const Icon(
                                Icons.pause,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                          );
                        case MaxVideoState.error:
                          return const SizedBox();
                      }
                    } else {
                      if (_maxCtr.maxVideoState == MaxVideoState.loading) {
                        return loadingWidget;
                      }
                      return const SizedBox();
                    }
                  },
                ),
              ),
              if (!kIsWeb)
                GetBuilder<MaxGetXVideoController>(
                  tag: tag,
                  id: 'full-screen',
                  builder: (_maxCtr) => _maxCtr.isFullScreen
                      ? const SizedBox()
                      : GetBuilder<MaxGetXVideoController>(
                          tag: tag,
                          id: 'overlay',
                          builder: (_maxCtr) => _maxCtr.isOverlayVisible ||
                                  !_maxCtr.alwaysShowProgressBar
                              ? const SizedBox()
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: MaxProgressBar(
                                    tag: tag,
                                    alignment: Alignment.bottomCenter,
                                    maxProgressBarConfig:
                                        _maxCtr.maxProgressBarConfig,
                                  ),
                                ),
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}
