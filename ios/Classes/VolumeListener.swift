import Foundation
import AVFoundation
import MediaPlayer

@objc public class VolumeListener: NSObject {
    public static let shared = VolumeListener()
    
    private var audioSession: AVAudioSession?
    private var volumeChangeHandler: ((String) -> Void)?
    private var initialVolume: Float = 0.0
    
    private override init() {
        super.init()
    }
    
    @objc public func startListening(volumeChangeHandler: @escaping (String) -> Void) {
        self.volumeChangeHandler = volumeChangeHandler
        
        // Set up audio session
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(.playback, mode: .default)
            try audioSession?.setActive(true)
            
            // Get initial volume
            initialVolume = audioSession?.outputVolume ?? 0.0
            
            // Add volume change observer using KVO
            audioSession?.addObserver(self, forKeyPath: #keyPath(AVAudioSession.outputVolume), options: [.new, .old], context: nil)
            
            print("VolumeListener: Listening started successfully")
        } catch {
            print("VolumeListener: Error setting up audio session - \(error)")
        }
    }
    
    @objc public func stopListening() {
        // Remove KVO observer
        do {
            try audioSession?.removeObserver(self, forKeyPath: #keyPath(AVAudioSession.outputVolume))
        } catch {
            print("VolumeListener: Error removing observer - \(error)")
        }
        
        volumeChangeHandler = nil
        
        // Deactivate audio session
        do {
            try audioSession?.setActive(false)
        } catch {
            print("VolumeListener: Error deactivating audio session - \(error)")
        }
        
        print("VolumeListener: Listening stopped")
    }
    
    // KVO observation method
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(AVAudioSession.outputVolume),
              let audioSession = object as? AVAudioSession,
              let newVolume = change?[.newKey] as? Float,
              let oldVolume = change?[.oldKey] as? Float else {
            return
        }
        
        print("VolumeListener: Volume changed from \(oldVolume) to \(newVolume)")
        
        // Determine volume key press direction
        if newVolume > initialVolume {
            volumeChangeHandler?("up")
        } else if newVolume < initialVolume {
            volumeChangeHandler?("down")
        }
        
        // Update initial volume
        initialVolume = newVolume
    }
    
    deinit {
        stopListening()
    }
}