import 'dart:developer';

import '../../max_player.dart';

void maxLog(String message) =>
    MaxVideoPlayer.enableLogs ? log(message, name: 'max') : null;
