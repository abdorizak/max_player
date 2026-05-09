## 3.1.0

### New Features

- **Skip-10s buttons in mobile overlay**: The center cluster now renders an explicit `replay_10` button on the left and a `forward_10` button on the right of the play/pause icon. Both call `seekBackward(10s)` / `seekForward(10s)` and live inside the overlay's `AnimatedOpacity`, so they fade in and out together with the rest of the chrome — no app-side wiring needed for visibility sync.
- Previously, jumping by 10s required users to discover the left/right double-tap zones. The buttons make the same action discoverable for first-time users while leaving the double-tap zones intact.

## 3.0.1

- **Fix**: YouTube videos now extract HLS streams in addition to muxed streams, enabling higher quality options (720p, 1080p+) when available. Previously only muxed streams were used which are typically limited to 360p.

## 3.0.0

### New Features

- **Position & Status Streams**: `positionStream`, `bufferedPositionStream`, `statusStream` for real-time playback monitoring.
- **Player Status Enum**: `MaxPlayerStatus` with states: idle, initializing, playing, paused, buffering, completed, error.
- **Playback Speed API**: `setPlaybackSpeed(double)`, `currentSpeed` getter, configurable `availableSpeeds` in `MaxPlayerConfig`.
- **Error Handling**: `onError` stream with `MaxPlayerError` (type: network, format, source, timeout, unknown), `retry()` method, built-in error UI with retry button.
- **Buffering Timeout**: Configurable `bufferingTimeoutDuration` (default 15s) — surfaces timeout error when buffering stalls.
- **State Getters**: `isPlaying`, `isPaused`, `isBuffering`, `progress` (0.0–1.0), `totalDuration`.
- **YouTube Live Stream Fix**: Fallback extraction via `getManifest(requireWatchPage: false)` when `getHttpLiveStreamUrl` fails due to bot detection.

### UI Improvements

- **YouTube-Style Overlay**: Top and bottom gradient overlays for better readability over video content.
- **Redesigned Bottom Controls**: Progress bar on top, time + fullscreen below — matches YouTube/Netflix layout.
- **Isolated Play/Pause Button**: Centered play/pause no longer mixed with double-tap seek zones.
- **Compact Controls**: Smaller icons and tighter spacing for a cleaner look.

### Code Quality

- **Upgraded `very_good_analysis`**: From ^5.0.0+1 to ^10.0.0 (resolved to 10.1.0).
- **Fixed 200+ lint warnings**: Constructor ordering, `super.key`, package imports, discarded futures, line lengths, type inference, and more.
- **Only 3 info-level issues remain**: All `avoid_positional_boolean_parameters` on existing public API callbacks — cannot change without breaking backward compatibility.
- **Removed `flutter_lints`** dev dependency (replaced by `very_good_analysis`).

### Example App

- **6 example screens**: Basic player, speed & streams, error handling, video list, custom theme.
- **13 sample videos** from Google's public sample library.
- **Platform configs**: Android `networkSecurityConfig` and iOS `NSAppTransportSecurity` for HTTP URLs.

### Breaking Changes

- `videoPlaybackSpeeds` (List\<String\>) replaced by `MaxPlayerConfig.availableSpeeds` (List\<double\>). The speed selector UI now reads from config.
- `setDoubeTapForwarDuration()` deprecated in favor of `doubleTapForwardDuration` setter.

### Migration from 2.x

- Wrap your app root with `ProviderScope` (required by `flutter_riverpod`).
- If you used `videoPlaybackSpeeds`, move speed values to `MaxPlayerConfig(availableSpeeds: [...])`.
- All existing `MaxPlayerController` and `MaxVideoPlayer` APIs continue to work unchanged.

## 2.0.1

- **Fix**: Resolved `Null check operator used on a null value` in `MaxPlayerController`.
- **Feature**: Added comprehensive `example` project.
- **Fix**: Exported `MaxPlayerTheme` and fixed `SystemUiMode` usage in example.
- **Docs**: Updated README with comprehensive usage examples including `networkQualityUrls` and `vimeoPrivateVideos`.

## 2.0.0

- **Breaking Change**: Removed all web-specific code and dependencies to focus on mobile platforms.
- **Refactor**: Renamed controller files and classes to remove "GetX" naming and standardized structure.
- **Docs**: Updated README.md with Usage, License, Author, and Contribution guidelines.
- **Fix**: Fixed various analysis issues and file naming typos.

## 1.1.1

- Version 1.1.1 of max_player package.
