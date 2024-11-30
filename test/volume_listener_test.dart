import 'package:flutter_test/flutter_test.dart';
import 'package:volume_listener/volume_listener.dart';
import 'package:volume_listener/volume_listener_platform_interface.dart';
import 'package:volume_listener/volume_listener_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVolumeListenerPlatform
    with MockPlatformInterfaceMixin
    implements VolumeListenerPlatform {
  @override
  void addListener(void Function(VolumeKey p1) onVolumeChangeListener) {}

  @override
  void removeListener() {}
}

void main() {
  final VolumeListenerPlatform initialPlatform =
      VolumeListenerPlatform.instance;

  test('$MethodChannelVolumeListener is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVolumeListener>());
  });

  test('getPlatformVersion', () async {
    MockVolumeListenerPlatform fakePlatform = MockVolumeListenerPlatform();
    VolumeListenerPlatform.instance = fakePlatform;

    final List<VolumeKey> events = <VolumeKey>[];

    fakePlatform.addListener((VolumeKey event) {
      events.add(event);
    });

    expect(events, isEmpty);

    fakePlatform.addListener((VolumeKey event) {
      events.add(event);
    });

    expect(events, isEmpty);

    fakePlatform.addListener((VolumeKey event) {
      events.add(event);
    });
  });
}
