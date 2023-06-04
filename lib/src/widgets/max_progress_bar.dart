// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:max_player/max_player.dart';

import '../controllers/max_getx_video_controller.dart';

/// Renders progress bar for the video using custom paint.
class MaxProgressBar extends StatefulWidget {
  const MaxProgressBar({
    Key? key,
    MaxProgressBarConfig? maxProgressBarConfig,
    this.onDragStart,
    this.onDragEnd,
    this.onDragUpdate,
    this.alignment = Alignment.center,
    required this.tag,
  })  : maxProgressBarConfig =
            maxProgressBarConfig ?? const MaxProgressBarConfig(),
        super(key: key);

  final MaxProgressBarConfig maxProgressBarConfig;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;
  final Alignment alignment;
  final String tag;

  @override
  State<MaxProgressBar> createState() => _MaxProgressBarState();
}

class _MaxProgressBarState extends State<MaxProgressBar> {
  late final maxCtr = Get.find<MaxGetXVideoController>(tag: widget.tag);
  late VideoPlayerValue? videoPlayerValue = maxCtr.videoCtr?.value;
  bool _controllerWasPlaying = false;

  void seekToRelativePosition(Offset globalPosition) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position =
          (videoPlayerValue?.duration ?? Duration.zero) * relative;
      maxCtr.seekTo(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (videoPlayerValue == null) return const SizedBox();

    return GetBuilder<MaxGetXVideoController>(
      tag: widget.tag,
      id: 'video-progress',
      builder: (maxCtr) {
        videoPlayerValue = maxCtr.videoCtr?.value;
        return LayoutBuilder(
          builder: (context, size) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: _progressBar(size),
              onHorizontalDragStart: (DragStartDetails details) {
                if (!videoPlayerValue!.isInitialized) {
                  return;
                }
                _controllerWasPlaying =
                    maxCtr.videoCtr?.value.isPlaying ?? false;
                if (_controllerWasPlaying) {
                  maxCtr.videoCtr?.pause();
                }

                if (widget.onDragStart != null) {
                  widget.onDragStart?.call();
                }
              },
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                if (!videoPlayerValue!.isInitialized) {
                  return;
                }
                maxCtr.isShowOverlay(true);
                seekToRelativePosition(details.globalPosition);

                widget.onDragUpdate?.call();
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                if (_controllerWasPlaying) {
                  maxCtr.videoCtr?.play();
                }
                maxCtr.toggleVideoOverlay();

                if (widget.onDragEnd != null) {
                  widget.onDragEnd?.call();
                }
              },
              onTapDown: (TapDownDetails details) {
                if (!videoPlayerValue!.isInitialized) {
                  return;
                }
                seekToRelativePosition(details.globalPosition);
              },
            );
          },
        );
      },
    );
  }

  MouseRegion _progressBar(BoxConstraints size) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Padding(
        padding: widget.maxProgressBarConfig.padding,
        child: SizedBox(
          width: size.maxWidth,
          height: widget.maxProgressBarConfig.circleHandlerRadius,
          child: Align(
            alignment: widget.alignment,
            child: GetBuilder<MaxGetXVideoController>(
              tag: widget.tag,
              id: 'overlay',
              builder: (maxCtr) => CustomPaint(
                painter: _ProgressBarPainter(
                  videoPlayerValue!,
                  maxProgressBarConfig: widget.maxProgressBarConfig.copyWith(
                    circleHandlerRadius: maxCtr.isOverlayVisible ||
                            widget
                                .maxProgressBarConfig.alwaysVisibleCircleHandler
                        ? widget.maxProgressBarConfig.circleHandlerRadius
                        : 0,
                  ),
                ),
                size: Size(
                  double.maxFinite,
                  widget.maxProgressBarConfig.height,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, {this.maxProgressBarConfig});

  VideoPlayerValue value;
  MaxProgressBarConfig? maxProgressBarConfig;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double height = maxProgressBarConfig!.height;
    final double width = size.width;
    final double curveRadius = maxProgressBarConfig!.curveRadius;
    final double circleHandlerRadius =
        maxProgressBarConfig!.circleHandlerRadius;
    final Paint backgroundPaint =
        maxProgressBarConfig!.getBackgroundPaint != null
            ? maxProgressBarConfig!.getBackgroundPaint!(
                width: width,
                height: height,
                circleHandlerRadius: circleHandlerRadius,
              )
            : Paint()
          ..color = maxProgressBarConfig!.backgroundColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(width, height),
        ),
        Radius.circular(curveRadius),
      ),
      backgroundPaint,
    );
    if (value.isInitialized == false) {
      return;
    }

    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? width : playedPartPercent * width;

    for (final DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * width;
      final double end = range.endFraction(value.duration) * width;

      final Paint bufferedPaint = maxProgressBarConfig!.getBufferedPaint != null
          ? maxProgressBarConfig!.getBufferedPaint!(
              width: width,
              height: height,
              playedPart: playedPart,
              circleHandlerRadius: circleHandlerRadius,
              bufferedStart: start,
              bufferedEnd: end,
            )
          : Paint()
        ..color = maxProgressBarConfig!.bufferedBarColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, 0),
            Offset(end, height),
          ),
          Radius.circular(curveRadius),
        ),
        bufferedPaint,
      );
    }

    final Paint playedPaint = maxProgressBarConfig!.getPlayedPaint != null
        ? maxProgressBarConfig!.getPlayedPaint!(
            width: width,
            height: height,
            playedPart: playedPart,
            circleHandlerRadius: circleHandlerRadius,
          )
        : Paint()
      ..color = maxProgressBarConfig!.playingBarColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset.zero,
          Offset(playedPart, height),
        ),
        Radius.circular(curveRadius),
      ),
      playedPaint,
    );

    final Paint handlePaint =
        maxProgressBarConfig!.getCircleHandlerPaint != null
            ? maxProgressBarConfig!.getCircleHandlerPaint!(
                width: width,
                height: height,
                playedPart: playedPart,
                circleHandlerRadius: circleHandlerRadius,
              )
            : Paint()
          ..color = maxProgressBarConfig!.circleHandlerColor;

    canvas.drawCircle(
      Offset(playedPart, height / 2),
      circleHandlerRadius,
      handlePaint,
    );
  }
}
