import Flutter
import UIKit
import AVFoundation

public class VolumeListenerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = VolumeListenerPlugin()
        
        // Create event channel
        let eventChannel = FlutterEventChannel(
            name: "volume_listener", 
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("VolumeListenerPlugin: Starting to listen")
        
        self.eventSink = events
        
        // Start listening to volume changes
        VolumeListener.shared.startListening { [weak self] volumeKey in
            print("VolumeListenerPlugin: Volume event received - \(volumeKey)")
            self?.eventSink?(volumeKey)
        }
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("VolumeListenerPlugin: Cancelling listener")
        
        // Stop listening when stream is cancelled
        VolumeListener.shared.stopListening()
        self.eventSink = nil
        return nil
    }
}