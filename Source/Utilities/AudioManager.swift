//
//  AudioManager.swift
//  CodingAssignment2021
//
//  Created by Jeff Huang on 1/20/21.
//
import AVFoundation
import SoundAnalysis

public class AudioManager: NSObject {
 
    static let shared = AudioManager()
    
    // Private Properties
    private let audioEngine: AVAudioEngine!
    private let inputBus: AVAudioNodeBus!
    private let inputFormat: AVAudioFormat!
    private let streamAnalyzer: SNAudioStreamAnalyzer!
    private let analysisQueue = DispatchQueue(label: "com.example.AnalysisQueue")
    
    // Public Properties
    // Assign an listener function to receive callbacks
    // Callbacks will be received in the main thread
    public var eventListener: ((_ eventIdentifier: String, _ confidence: Double, _ timestamp: Double) -> Void)?
  

    private override init() {
        // Set Sampling Rate
        do {
            try AVAudioSession.sharedInstance().setPreferredSampleRate(16000)
        } catch { print("Could not set sampling rate to 16kHz: Description \n", error.localizedDescription)}
        audioEngine = AVAudioEngine()
        inputBus = AVAudioNodeBus(0)
        inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        super.init()
        setupAudioSession()
        setupAudioEngineGraph()
        setupStreamAnalyzer()
    }
    

    // MARK: - Public Methods
    /// Use this to start getting audio data from microphone.
    public func start() {
        startAudioEngine()
        startAudioSession()
    }

    /// Use this to stop receiving audio data from microphone.
    public func stop() {
        stopAudioEngine()
        stopAudioSession()
    }
    
    /// This method allows you to listen to the microphone data. Use this to pipe
    /// audio data to the deep learning model.
    public func installTap(tapBlock: @escaping AVAudioNodeTapBlock) {
        removeTap()
        audioEngine.inputNode.installTap(
            onBus: 0,
            bufferSize: 15600,
            format: audioEngine.inputNode.outputFormat(forBus: 0),
            block: tapBlock
        )
    }
    
    public func removeTap() {
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    public func getInputNodeFormat() -> AVAudioFormat {
        return audioEngine.inputNode.outputFormat(forBus: 0)
    }
    
    // MARK: - Private Methods

    
    private func setupAudioSession() {
        let category: AVAudioSession.Category = .playAndRecord
        let mode: AVAudioSession.Mode = .default
        let options: AVAudioSession.CategoryOptions = [
            .mixWithOthers
        ]
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(category, mode: mode, options: options)
            try session.setPreferredIOBufferDuration(256/16000)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setupAudioEngineGraph() {
        audioEngine.connect(audioEngine.inputNode,
                            to: audioEngine.mainMixerNode,
                            format: audioEngine.inputNode.inputFormat(forBus: 0))
        
        audioEngine.connect(audioEngine.mainMixerNode,
                            to: audioEngine.outputNode,
                            format: audioEngine.mainMixerNode.inputFormat(forBus: 0))
        
        // Set the output volume to almost zero so we don't produce any sound
        audioEngine.mainMixerNode.outputVolume = 0.0001
        audioEngine.prepare()
    }
    
    private func setupStreamAnalyzer() {
        do {
            guard let modelUrl = Bundle.main.url(forResource: "ESC10SoundClassifierModel", withExtension: "mlmodelc"),
                  let model = try? MLModel(contentsOf: modelUrl) else {
                      throw SNError(.invalidModel)
                  }
            let request = try SNClassifySoundRequest(mlModel: model)
            try streamAnalyzer.add(request, withObserver: self)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func startAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setActive( true, options: .notifyOthersOnDeactivation )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func stopAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setActive( false, options: .notifyOthersOnDeactivation )
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func startAudioEngine() {
        do {
            try audioEngine.start()
            installTap(tapBlock: analyzeAudio)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    private func stopAudioEngine() {
        removeTap()
        audioEngine.stop()
    }
    
    private func analyzeAudio(buffer: AVAudioBuffer, at time: AVAudioTime) {
        analysisQueue.async {
            self.streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
        }
    }
    
}

// MARK: SNResultsObserving protocol conformance
extension AudioManager: SNResultsObserving {

    public func request(_ request: SNRequest, didProduce result: SNResult) {

        guard let result = result as? SNClassificationResult else  { return }

        guard let classification = result.classifications.first else {return}
        
        DispatchQueue.main.async {
            self.eventListener?(classification.identifier, classification.confidence, Date().timeIntervalSince1970)
        }
    }

    public func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
    }

    public func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
    }
}
