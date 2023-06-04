part of 'package:max_player/src/max_player.dart';

class FullScreenView extends StatefulWidget {
  final String tag;
  const FullScreenView({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView>
    with TickerProviderStateMixin {
  late MaxGetXVideoController _maxCtr;
  @override
  void initState() {
    _maxCtr = Get.find<MaxGetXVideoController>(tag: widget.tag);
    _maxCtr.fullScreenContext = context;
    _maxCtr.keyboardFocusWeb?.removeListener(_maxCtr.keyboadListner);

    super.initState();
  }

  @override
  void dispose() {
    _maxCtr.keyboardFocusWeb?.requestFocus();
    _maxCtr.keyboardFocusWeb?.addListener(_maxCtr.keyboadListner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingWidget = _maxCtr.onLoading?.call(context) ??
        const CircularProgressIndicator(
          backgroundColor: Colors.black87,
          color: Colors.white,
          strokeWidth: 2,
        );

    return WillPopScope(
      onWillPop: () async {
        if (kIsWeb) {
          await _maxCtr.disableFullScreen(
            context,
            widget.tag,
            enablePop: false,
          );
        }
        if (!kIsWeb) await _maxCtr.disableFullScreen(context, widget.tag);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GetBuilder<MaxGetXVideoController>(
          tag: widget.tag,
          builder: (_maxCtr) => Center(
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: _maxCtr.videoCtr == null
                      ? loadingWidget
                      : _maxCtr.videoCtr!.value.isInitialized
                          ? _MaxCoreVideoPlayer(
                              tag: widget.tag,
                              videoPlayerCtr: _maxCtr.videoCtr!,
                              videoAspectRatio:
                                  _maxCtr.videoCtr?.value.aspectRatio ?? 16 / 9,
                            )
                          : loadingWidget,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
