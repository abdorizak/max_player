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
        builder: (_maxCtr) {
          return MaterialIconButton(
            toolTipMesg: _maxCtr.maxPlayerLabels.settings,
            color: Colors.white,
            child: const Icon(Icons.settings),
            onPressed: () => _maxCtr.isFullScreen
                ? _maxCtr.isWebPopupOverlayOpen = true
                : _maxCtr.isWebPopupOverlayOpen = false,
            onTapDown: (details) async {
              final _settingsMenu = await showMenu<String>(
                context: context,
                items: [
                  if (_maxCtr.vimeoOrVideoUrls.isNotEmpty)
                    PopupMenuItem(
                      value: 'OUALITY',
                      child: _bottomSheetTiles(
                        title: _maxCtr.maxPlayerLabels.quality,
                        icon: Icons.video_settings_rounded,
                        subText: '${_maxCtr.vimeoPlayingVideoQuality}p',
                      ),
                    ),
                  PopupMenuItem(
                    value: 'LOOP',
                    child: _bottomSheetTiles(
                      title: _maxCtr.maxPlayerLabels.loopVideo,
                      icon: Icons.loop_rounded,
                      subText: _maxCtr.isLooping
                          ? _maxCtr.maxPlayerLabels.optionEnabled
                          : _maxCtr.maxPlayerLabels.optionDisabled,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'SPEED',
                    child: _bottomSheetTiles(
                      title: _maxCtr.maxPlayerLabels.playbackSpeed,
                      icon: Icons.slow_motion_video_rounded,
                      subText: _maxCtr.currentPaybackSpeed,
                    ),
                  ),
                ],
                position: RelativeRect.fromSize(
                  details.globalPosition & Size.zero,
                  MediaQuery.of(context).size,
                ),
              );
              switch (_settingsMenu) {
                case 'OUALITY':
                  await _onVimeoQualitySelect(details, _maxCtr);
                  break;
                case 'SPEED':
                  await _onPlaybackSpeedSelect(details, _maxCtr);
                  break;
                case 'LOOP':
                  _maxCtr.isWebPopupOverlayOpen = false;
                  await _maxCtr.toggleLooping();
                  break;
                default:
                  _maxCtr.isWebPopupOverlayOpen = false;
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _onPlaybackSpeedSelect(
    TapDownDetails details,
    MaxGetXVideoController _maxCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: _maxCtr.videoPlaybackSpeeds
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text(e),
              ),
              onTap: () {
                _maxCtr.setVideoPlayBack(e);
              },
            ),
          )
          .toList(),
      position: RelativeRect.fromSize(
        details.globalPosition & Size.zero,
        // ignore: use_build_context_synchronously
        MediaQuery.of(context).size,
      ),
    );
    _maxCtr.isWebPopupOverlayOpen = false;
  }

  Future<void> _onVimeoQualitySelect(
    TapDownDetails details,
    MaxGetXVideoController _maxCtr,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    );
    await showMenu(
      context: context,
      items: _maxCtr.vimeoOrVideoUrls
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text('${e.quality}p'),
              ),
              onTap: () {
                _maxCtr.changeVideoQuality(
                  e.quality,
                );
              },
            ),
          )
          .toList(),
      position: RelativeRect.fromSize(
        details.globalPosition & Size.zero,
        // ignore: use_build_context_synchronously
        MediaQuery.of(context).size,
      ),
    );
    _maxCtr.isWebPopupOverlayOpen = false;
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
