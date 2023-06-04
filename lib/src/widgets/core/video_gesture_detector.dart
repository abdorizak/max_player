part of 'package:max_player/src/max_player.dart';

class _VideoGestureDetector extends StatelessWidget {
  final Widget? child;
  final void Function()? onDoubleTap;
  final void Function()? onTap;
  final String tag;

  const _VideoGestureDetector({
    Key? key,
    this.child,
    this.onDoubleTap,
    this.onTap,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return MouseRegion(
      onHover: (event) => _maxCtr.onOverlayHover(),
      onExit: (event) => _maxCtr.onOverlayHoverExit(),
      child: GestureDetector(
        onTap: onTap ?? _maxCtr.toggleVideoOverlay,
        onDoubleTap: onDoubleTap,
        child: child,
      ),
    );
  }
}
