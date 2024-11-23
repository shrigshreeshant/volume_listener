import 'package:flutter/services.dart';
import 'package:volume_listener/volume_listener.dart';

import 'volume_listener_platform_interface.dart';

/// An implementation of [VolumeListenerPlatform] that uses method channels.
class MethodChannelVolumeListener implements VolumeListenerPlatform {
  static const EventChannel eventChannel = EventChannel('volume_listener');

  @override
  void addListener(void Function(VolumeKey p1) onVolumeChangeListener) {
    eventChannel.receiveBroadcastStream().listen((event) {
      if (event == 'up') {
        onVolumeChangeListener(VolumeKey.up);
      } else if (event == 'down') {
        onVolumeChangeListener(VolumeKey.down);
      }
    });
  }

  @override
  void removeListener() {
    eventChannel.receiveBroadcastStream().listen(null);
  }
}
