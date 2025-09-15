package com.folksable.volume_listener

import android.view.KeyEvent
import com.folksable.volume_listener.VolumeListenerPlugin.Companion.eventSink
import io.flutter.embedding.android.FlutterFragmentActivity


open class VolumeListenerActivity(): FlutterFragmentActivity() {

    public override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            eventSink?.success("down")
            return true
        } else if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            eventSink?.success("up")
            return true
        }
        return super.onKeyDown(keyCode, event)
    }
}