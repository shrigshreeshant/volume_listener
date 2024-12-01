# Volume Listener

a flutter plugin to listen to volume button press events on android and ios.

## Getting Started

### Android setup

```kotlin
import com.folksable.volume_listener.VolumeListenerActivity

/// extend your MainActivity with VolumeListenerActivity, and remove FlutterActivity
class MainActivity: VolumeListenerActivity() {
    // ...
}
```

```dart

import 'package:volume_listener/volume_listener.dart';

void main() {
    VolumeListener.addListener((VolumeKey event) {
        switch (event) {
            case VolumeKey.up:
                print('Volume Up'); break;
            case VolumeKey.down:
                print('Volume Down'); break;
            // for iOS 17.2+ 
            case VolumeKey.capture:
                print('iOS Hardware Camera Capture'); 
                break;
        }
    });
  
    // stop listening
    VolumeListener.removeListener();
}
```



