import 'volume_listener_platform_interface.dart';

class VolumeListener {
  static void addListener(void Function(VolumeKey) onVolumeChangeListener) {
    VolumeListenerPlatform.instance.addListener(onVolumeChangeListener);
  }

  static void removeListener() {
    VolumeListenerPlatform.instance.removeListener();
  }
}

enum VolumeKey {
  up,
  down,
}
