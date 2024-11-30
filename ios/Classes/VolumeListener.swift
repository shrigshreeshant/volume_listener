import Foundation
import AVFoundation
import AVKit
import MediaPlayer

@objc public class VolumeListener: NSObject {
    public static let shared = VolumeListener()
    
    private weak var audioSession: AVAudioSession?
    private var volumeChangeHandler: ((String) -> Void)?
    private var initialVolume: Float = 0.0
    private var volumeTimer: Timer?
    private var systemVolumeView: MPVolumeView?
    
    // New property for hardware event interaction
    private var eventInteraction: Any? // Use Any to avoid version-specific compilation
    
    // Increased sensitivity parameters
    private let volumeChangeThreshold: Float = 0.02 // Smaller threshold for more sensitive detection
    private let timerInterval: TimeInterval = 0.05 // (20 times per second)
    
    private override init() {
        super.init()
        audioSession = AVAudioSession.sharedInstance()
        setupSystemVolumeView()
        setupHardwareEventListener()
    }
    
    private func setupSystemVolumeView() {
        // Create an invisible volume view to intercept volume changes
        systemVolumeView = MPVolumeView(frame: .zero)
        systemVolumeView?.showsRouteButton = false
        systemVolumeView?.showsVolumeSlider = false
    }
    
    private func setupHardwareEventListener() {
        if #available(iOS 17.2, *) {
            // Explicitly specify the type for AVCaptureEvent and AVCaptureEventInteraction
            let interaction = AVCaptureEventInteraction{ [weak self] event in
                if (event.phase == .ended) {
                    self?.volumeChangeHandler?("capture")
                }
            }
            eventInteraction = interaction
        }
    }
    
    @objc public func startListening(volumeChangeHandler: @escaping (String) -> Void) {
        self.volumeChangeHandler = volumeChangeHandler
        
        
        // Fallback to existing timer-based method
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
            
            print("VolumeListener: Listening started with timer method")
        } catch {
            print("VolumeListener: Error setting up audio session - \(error)")
        }
    }
    
    private func startVolumeTimer() {
        // Stop any existing timer
        volumeTimer?.invalidate()
        
        // Start a new timer to check volume more frequently
        volumeTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            self?.checkVolumeChange()
        }
    }
    
    private func checkVolumeChange() {
        guard let audioSession = self.audioSession else {
            print("VolumeListener: Audio session no longer available")
            return
        }
        
        let currentVolume = audioSession.outputVolume
        
        // Detect volume changes with a smaller threshold to prevent multiple triggers
        if abs(currentVolume - initialVolume) > volumeChangeThreshold {
            if currentVolume > initialVolume {
                volumeChangeHandler?("up")
            } else {
                volumeChangeHandler?("down")
            }
            
            initialVolume = currentVolume
        }
    }
    
    @objc public func stopListening() {
        // Stop hardware event listener if available
        if #available(iOS 17.2, *) {
            if let interaction = eventInteraction as? AVCaptureEventInteraction {
                interaction.isEnabled = false
                print("VolumeListener: Stopped hardware event interaction")
            }
        }
        
        // Stop volume timer
        volumeTimer?.invalidate()
        volumeTimer = nil
        
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
