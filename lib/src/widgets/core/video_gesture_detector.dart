// ignore_for_file: no_leading_underscores_for_local_identifiers

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
    final maxCtr = Get.find<MaxGetXVideoController>(tag: tag);
    return MouseRegion(
      onHover: (event) => maxCtr.onOverlayHover(),
      onExit: (event) => maxCtr.onOverlayHoverExit(),
      child: GestureDetector(
        onTap: onTap ?? maxCtr.toggleVideoOverlay,
        onDoubleTap: onDoubleTap,
        child: child,
      ),
    );
  }
}
