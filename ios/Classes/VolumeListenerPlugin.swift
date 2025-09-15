import Flutter
import UIKit
import AVFoundation

public class VolumeListenerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var handler: VolumeListener?
    
    // MARK: - FlutterPlugin
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = VolumeListenerPlugin()
        
        let eventChannel = FlutterEventChannel(
            name: "volume_listener",
            binaryMessenger: registrar.messenger()
        )
        eventChannel.setStreamHandler(instance)
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("VolumeListenerPlugin: Starting to listen")
        self.eventSink = events
        
        // Start listening to volume button presses
        handler = VolumeListener.volumeButtonHandler(
            upBlock: { [weak self] in
                self?.eventSink?("up")
            },
            downBlock: { [weak self] in
                self?.eventSink?("down")
            }
        )
        handler?.startHandler()
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("VolumeListenerPlugin: Cancelling listener")
        
        handler?.stopHandler()
        handler = nil
        eventSink = nil
        return nil
    }
}
