// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers

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
  late MaxGetXVideoController maxCtr;
  @override
  void initState() {
    maxCtr = Get.find<MaxGetXVideoController>(tag: widget.tag);
    maxCtr.fullScreenContext = context;
    maxCtr.keyboardFocusWeb?.removeListener(maxCtr.keyboadListner);

    super.initState();
  }

  @override
  void dispose() {
    maxCtr.keyboardFocusWeb?.requestFocus();
    maxCtr.keyboardFocusWeb?.addListener(maxCtr.keyboadListner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadingWidget = maxCtr.onLoading?.call(context) ??
        const CircularProgressIndicator(
          backgroundColor: Colors.black87,
          color: Colors.white,
          strokeWidth: 2,
        );

    return WillPopScope(
      onWillPop: () async {
        if (kIsWeb) {
          await maxCtr.disableFullScreen(
            context,
            widget.tag,
            enablePop: false,
          );
        }
        if (!kIsWeb) await maxCtr.disableFullScreen(context, widget.tag);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GetBuilder<MaxGetXVideoController>(
          tag: widget.tag,
          builder: (maxCtr) => Center(
            child: ColoredBox(
              color: Colors.black,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: maxCtr.videoCtr == null
                      ? loadingWidget
                      : maxCtr.videoCtr!.value.isInitialized
                          ? _MaxCoreVideoPlayer(
                              tag: widget.tag,
                              videoPlayerCtr: maxCtr.videoCtr!,
                              videoAspectRatio:
                                  maxCtr.videoCtr?.value.aspectRatio ?? 16 / 9,
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
