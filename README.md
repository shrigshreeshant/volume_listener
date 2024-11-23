# Volume Listener

a flutter plugin to listen to volume button press events on android and ios.

## Getting Started

```dart

import 'package:volume_listener/volume_listener.dart';

void main() {
    VolumeListener.addListener((VolumeKey event) {
        print(event);
    });
  
    // stop listening
    VolumeListener.removeListener();
}
```



