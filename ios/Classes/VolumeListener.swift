import UIKit
import MediaPlayer
import AVFoundation

// MARK: - VolumeListener

class VolumeListener: NSObject {
    
    // MARK: - Properties
    
    private var initialVolume: Float = 0.0
    private var session: AVAudioSession!
    private var volumeView: MPVolumeView!
    
    private var appIsActive = true
    private var isStarted = false
    private var isAdjustingInitialVolume = false
    private var isResettingVolume = false
    
    private var debounceWorkItem: DispatchWorkItem?
    private let debounceInterval: TimeInterval = 0.05
    
    public var upBlock: (() -> Void)?
    public var downBlock: (() -> Void)?
    
    public var sessionCategory: AVAudioSession.Category = .playback
    public var sessionOptions: AVAudioSession.CategoryOptions = .mixWithOthers
    
    private let maxVolume: Float = 0.99999
    private let minVolume: Float = 0.00001
    
    private var observer: Any?
    
    // MARK: - Init
    
    override init() {
        super.init()
        volumeView = MPVolumeView(frame: .zero)
        if let window = UIApplication.shared.windows.first {
            window.addSubview(volumeView)
        }
        volumeView.isHidden = true
    }
    
    deinit {
        stopHandler()
        DispatchQueue.main.async { [weak volumeView] in
            volumeView?.removeFromSuperview()
        }
    }
    
    // MARK: - Public
    
    func startHandler() {
        setupSession()
        volumeView.isHidden = false
        perform(#selector(setupSession), with: nil, afterDelay: 1)
    }
    
    func stopHandler() {
        guard isStarted else { return }
        
        isStarted = false
        volumeView.isHidden = true
        
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    @objc private func setupSession() {
        guard !isStarted else { return }
        isStarted = true
        
        session = AVAudioSession.sharedInstance()
        setInitialVolume()
        
        do {
            try session.setCategory(sessionCategory, options: sessionOptions)
            try session.setActive(true)
        } catch {
            print("AudioSession error: \(error)")
            return
        }
        
        // KVO fallback
        session.addObserver(self,
                            forKeyPath: "outputVolume",
                            options: [.old, .new],
                            context: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioSessionInterrupted(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidChangeActive(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidChangeActive(_:)),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        volumeView.isHidden = true
    }
    
    private func setInitialVolume() {
        initialVolume = session.outputVolume
        print("Initial volume (raw from session): \(initialVolume)")
        
        if initialVolume > maxVolume {
            initialVolume = maxVolume
            print("Clamped to maxVolume: \(initialVolume)")
        } else if initialVolume < minVolume {
            initialVolume = minVolume
            print("Clamped to minVolume: \(initialVolume)")
        }
        
        isAdjustingInitialVolume = true
        print("Final initialVolume set to: \(initialVolume)")
        setSystemVolume(initialVolume)
        isAdjustingInitialVolume = false
    }
    
    // MARK: - Notifications
    
    @objc private func audioSessionInterrupted(_ notification: Notification) {
        guard let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            print("Audio session interruption began")
        case .ended:
            print("Audio session interruption ended")
            do { try session.setActive(true) }
            catch { print("Error resuming session: \(error)") }
        default:
            break
        }
    }
    
    @objc private func applicationDidChangeActive(_ notification: Notification) {
        appIsActive = (notification.name == UIApplication.didBecomeActiveNotification)
        if appIsActive && isStarted {
            setInitialVolume()
        }
    }
    
    // MARK: - Volume Handling
    
    private func handleVolumeChange(newVolume: Float, oldVolume: Float) {
        guard appIsActive else { return }
        
        if isAdjustingInitialVolume {
            print("🔁 Ignoring self-triggered initial volume")
            isAdjustingInitialVolume = false
            return
        }
        
        if isResettingVolume {
            print("🔁 Ignoring self-triggered reset")
            isResettingVolume = false
            return
        }
        
        print("Initial Volume: \(initialVolume)")
        print("New vol: \(newVolume)")
        print("Old vol: \(oldVolume)")
        
        var triggered = false
        
        // Edge cases: max/min
        if newVolume >= maxVolume {
            print("📈 Edge UP (at max volume)")
            upBlock?()
            triggered = true
        } else if newVolume <= minVolume {
            print("📉 Edge DOWN (at min volume)")
            downBlock?()
            triggered = true
        }
        
        // Normal up/down detection
        if !triggered {
            if newVolume > oldVolume {
                print("➡️ Volume UP detected")
                upBlock?()
                triggered = true
            } else if newVolume < oldVolume {
                print("⬅️ Volume DOWN detected")
                downBlock?()
                triggered = true
            }
        }
        
        // Reset volume silently if needed
        if triggered {
            isResettingVolume = true
            setSystemVolume(initialVolume)
        }
    }
    
    // MARK: - KVO with debounce
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume",
           let newVolume = (change?[.newKey] as? Float),
           let oldVolume = (change?[.oldKey] as? Float) {
            
            // Debounce rapid events
            debounceWorkItem?.cancel()
            let workItem = DispatchWorkItem { [weak self] in
                self?.handleVolumeChange(newVolume: newVolume, oldVolume: oldVolume)
            }
            debounceWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: workItem)
        }
    }
    
    // MARK: - System Volume
    
    private func setSystemVolume(_ volume: Float) {
        guard let slider = volumeView.subviews.compactMap({ $0 as? UISlider }).first else { return }
        DispatchQueue.main.async {
            slider.value = volume
        }
    }
    
    // MARK: - Convenience
    
    static func volumeButtonHandler(upBlock: (() -> Void)?,
                                    downBlock: (() -> Void)?) -> VolumeListener {
        let instance = VolumeListener()
        instance.upBlock = upBlock
        instance.downBlock = downBlock
        return instance
    }
}
