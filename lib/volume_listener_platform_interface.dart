import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:volume_listener/volume_listener.dart';

import 'volume_listener_method_channel.dart';

abstract class VolumeListenerPlatform extends PlatformInterface {
  /// Constructs a VolumeListenerPlatform.
  VolumeListenerPlatform() : super(token: _token);

  static final Object _token = Object();

  static VolumeListenerPlatform _instance = MethodChannelVolumeListener();

  /// The default instance of [VolumeListenerPlatform] to use.
  ///
  /// Defaults to [MethodChannelVolumeListener].
  static VolumeListenerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VolumeListenerPlatform] when
  /// they register themselves.
  static set instance(VolumeListenerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  void addListener(void Function(VolumeKey) onVolumeChangeListener) {
    throw UnimplementedError('startListener() has not been implemented.');
  }

  void removeListener() {
    throw UnimplementedError('stopListener() has not been implemented.');
  }
}
