package com.folksable.volume_listener

import android.view.KeyEvent
import com.folksable.volume_listener.VolumeListenerPlugin.Companion.eventSink
import io.flutter.embedding.android.FlutterActivity


open class VolumeListenerActivity(): FlutterActivity() {

    public override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            eventSink?.success("down")
        } else if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            eventSink?.success("up")
        }
        return super.onKeyDown(keyCode, event)
    }
}