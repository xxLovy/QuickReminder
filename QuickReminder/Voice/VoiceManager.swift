//
//  VoiceManager.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/5.
//

import Foundation
import Speech

class VoiceManager {
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startListening(completion: @escaping (Result<String, Error>) -> Void) {
        // Check for authorization and start the audio engine and recognition task
        if recognitionTask != nil {
            // Stop the previous task before starting a new one
            stopListening()
        }
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                completion(.failure(NSError(domain: "VoiceManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition authorization was denied."])))
                return
            }
            
            do {
                try self.startAudioEngine()
                self.startRecognitionTask(completion: completion)
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func startAudioEngine() throws {
        // Configure and prepare the audio engine for recording
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func startRecognitionTask(completion: @escaping (Result<String, Error>) -> Void) {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let isFinal = result.isFinal
                let bestTranscription = result.bestTranscription.formattedString
                if isFinal {
                    completion(.success(bestTranscription))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    
    func stopListening() {
        // Ensure all components are properly stopped and reset
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Audio session could not be deactivated.")
        }
    }
}
