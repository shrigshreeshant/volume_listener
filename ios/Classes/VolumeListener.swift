import Foundation
import AVFoundation
import MediaPlayer

@objc public class VolumeListener: NSObject {
    public static let shared = VolumeListener()
    
    private weak var audioSession: AVAudioSession?
    private var volumeChangeHandler: ((String) -> Void)?
    private var initialVolume: Float = 0.0
    private var volumeTimer: Timer?
    private var systemVolumeView: MPVolumeView?
    
    private override init() {
        super.init()
        audioSession = AVAudioSession.sharedInstance()
        setupSystemVolumeView()
    }
    
    private func setupSystemVolumeView() {
        // Create an invisible volume view to intercept volume changes
        systemVolumeView = MPVolumeView(frame: .zero)
        systemVolumeView?.showsRouteButton = false
        systemVolumeView?.showsVolumeSlider = false
    }
    
    @objc public func startListening(volumeChangeHandler: @escaping (String) -> Void) {
        self.volumeChangeHandler = volumeChangeHandler
        
        guard let audioSession = self.audioSession else {
            print("VolumeListener: Failed to access audio session")
            return
        }
        
        do {
            // Configure audio session for background audio
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            
            // Get initial volume
            initialVolume = audioSession.outputVolume
            
            // Start periodic volume checking
            startVolumeTimer()
            
            print("VolumeListener: Listening started successfully")
        } catch {
            print("VolumeListener: Error setting up audio session - \(error)")
        }
    }
    
    private func startVolumeTimer() {
        // Stop any existing timer
        volumeTimer?.invalidate()
        
        // Start a new timer to check volume periodically
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkVolumeChange()
        }
    }
    
    private func checkVolumeChange() {
        guard let audioSession = self.audioSession else {
            print("VolumeListener: Audio session no longer available")
            return
        }
        
        let currentVolume = audioSession.outputVolume
        
        // Detect volume changes with a small threshold to prevent multiple triggers
        if abs(currentVolume - initialVolume) > 0.05 {
            if currentVolume > initialVolume {
                volumeChangeHandler?("up")
            } else {
                volumeChangeHandler?("down")
            }
            
            // Update initial volume
            initialVolume = currentVolume
        }
    }
    
    @objc public func stopListening() {
        // Stop volume timer
        volumeTimer?.invalidate()
        volumeTimer = nil
        
        // Clear the handler
        volumeChangeHandler = nil
        
        // Deactivate audio session
        guard let audioSession = self.audioSession else {
            print("VolumeListener: No audio session to deactivate")
            return
        }
        
        do {
            try audioSession.setActive(false)
        } catch {
            print("VolumeListener: Error deactivating audio session - \(error)")
        }
        
        print("VolumeListener: Listening stopped")
    }
    
    deinit {
        stopListening()
    }
}