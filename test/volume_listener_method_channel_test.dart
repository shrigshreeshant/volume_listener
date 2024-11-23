import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const EventChannel channel = EventChannel('volume_listener');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(channel,
            MockStreamHandler.inline(onListen: (arguments, events) {
      events.success('up');
      events.success('down');
    }));
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    final List<String> events = <String>[];

    channel.receiveBroadcastStream().listen((dynamic event) {
      events.add(event as String);
    });

    expect(events.first, 'up');
    expect(events.last, 'down');
  });
}
