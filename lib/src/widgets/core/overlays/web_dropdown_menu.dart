// ignore_for_file: use_build_context_synchronously

part of 'package:max_player/src/max_player.dart';

class _WebSettingsDropdown extends StatefulWidget {
  final String tag;

  const _WebSettingsDropdown({
    Key? key,
    required this.tag,
  }) : super(key: key);

  @override
  State<_WebSettingsDropdown> createState() => _WebSettingsDropdownState();
}

class _WebSettingsDropdownState extends State<_WebSettingsDropdown> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: Colors.white,
      ),
      child: GetBuilder<MaxGetXVideoController>(
        tag: widget.tag,
        builder: (maxCtr) {
          return MaterialIconButton(
            toolTipMesg: maxCtr.maxPlayerLabels.settings,
            color: Colors.white,
            child: const Icon(Icons.settings),
            onPressed: () => maxCtr.isFullScreen
                ? maxCtr.isWebPopupOverlayOpen = true
                : maxCtr.isWebPopupOverlayOpen = false,
            onTapDown: (details) async {
              final settingsMenu = await showMenu<String>(
                context: context,
                items: [
                  if (maxCtr.vimeoOrVideoUrls.isNotEmpty)
                    PopupMenuItem(
                      value: 'OUALITY',
                      child: _bottomSheetTiles(
                        title: maxCtr.maxPlayerLabels.quality,
                        icon: Icons.video_settings_rounded,
                        subText: '${maxCtr.vimeoPlayingVideoQuality}p',
                      ),
                    ),
                  PopupMenuItem(
                    value: 'LOOP',
                    child: _bottomSheetTiles(
                      title: maxCtr.maxPlayerLabels.loopVideo,
                      icon: Icons.loop_rounded,
                      subText: maxCtr.isLooping
                          ? maxCtr.maxPlayerLabels.optionEnabled
                          : maxCtr.maxPlayerLabels.optionDisabled,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'SPEED',
                    child: _bottomSheetTiles(
                      title: maxCtr.maxPlayerLabels.playbackSpeed,
                      icon: Icons.slow_motion_video_rounded,
                      subText: maxCtr.currentPaybackSpeed,
                    ),
                  ),
                ],
                position: RelativeRect.fromSize(
                  details.globalPosition & Size.zero,
                  MediaQuery.of(context).size,
                ),
              );
              switch (settingsMenu) {
                case 'OUALITY':
                  await _onVimeoQualitySelect(details, maxCtr);
                  break;
                case 'SPEED':
                  await _onPlaybackSpeedSelect(details, maxCtr);
                  break;
                case 'LOOP':
                  maxCtr.isWebPopupOverlayOpen = false;
                  await maxCtr.toggleLooping();
                  break;
                default:
                  maxCtr.isWebPopupOverlayOpen = false;
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _onPlaybackSpeedSelect(
    TapDownDetails details,
    MaxGetXVideoController maxCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: maxCtr.videoPlaybackSpeeds
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text(e),
              ),
              onTap: () {
                maxCtr.setVideoPlayBack(e);
              },
            ),
          )
          .toList(),
      position: RelativeRect.fromSize(
        details.globalPosition & Size.zero,
        MediaQuery.of(context).size,
      ),
    );
    maxCtr.isWebPopupOverlayOpen = false;
  }

  Future<void> _onVimeoQualitySelect(
    TapDownDetails details,
    MaxGetXVideoController maxCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: maxCtr.vimeoOrVideoUrls
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text('${e.quality}p'),
              ),
              onTap: () {
                maxCtr.changeVideoQuality(
                  e.quality,
                );
              },
            ),
          )
          .toList(),
      position: RelativeRect.fromSize(
        details.globalPosition & Size.zero,
        MediaQuery.of(context).size,
      ),
    );
    maxCtr.isWebPopupOverlayOpen = false;
  }

  Widget _bottomSheetTiles({
    required String title,
    required IconData icon,
    String? subText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(width: 20),
            Text(
              title,
            ),
            if (subText != null) const SizedBox(width: 10),
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
