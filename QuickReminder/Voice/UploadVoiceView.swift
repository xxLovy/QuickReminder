//
//  UploadVoiceView.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/5.
//

import SwiftUI

struct UploadVoiceView: View {
    enum SpeakMode {
        case holdToSpeak
        case clickToSpeak
    }
    
    @State private var transcribedText: String = ""
    @State private var speakMode: SpeakMode = .holdToSpeak
    @State private var isListening: Bool = false
    @State private var isLoading: Bool = false
    @State private var reminders: [Reminder] = [] // This will hold the fetched reminders
    @State private var selectedItems: [Bool] = [] // This will hold the selection state of reminders
    @State private var showReminderSelectionView: Bool = false // State to control the presentation of ReminderSelectionView
    @State private var showAlert: Bool = false // To show an alert if needed
    @State private var alertMessage: String = "" // The message for the alert
    private let voiceManager = VoiceManager()
    
    
    var body: some View {
        VStack {
            Picker("Speak Mode", selection: $speakMode) {
                Text("Hold to speak").tag(SpeakMode.holdToSpeak)
                Text("Click to speak").tag(SpeakMode.clickToSpeak)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Spacer()
            
            // Circular button for voice input
            Circle()
                .fill(isListening ? Color.green : Color.blue)
                .frame(width: 200, height: 200)
                .overlay(
                    Text(speakMode == .holdToSpeak ? "Hold to speak" : "Click to speak")
                        .foregroundColor(.white)
                )
                .padding()
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged({ _ in
                            if speakMode == .holdToSpeak && !isListening {
                                startListening()
                            }
                        })
                        .onEnded({ _ in
                            if speakMode == .holdToSpeak {
                                stopListening()
                            }
                        })
                )
                .simultaneousGesture(
                    TapGesture().onEnded {
                        if speakMode == .clickToSpeak {
                            isListening ? stopListening() : startListening()
                        }
                    }
                )
            
            Spacer()
            
            // Generate button
            Button(action: {
                generateFromVoice()
            }) {
                Text("Generate")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(transcribedText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(transcribedText.isEmpty)
            .padding()
            
            Spacer()
        }
        .navigationTitle("Upload Voice")
        .sheet(isPresented: $showReminderSelectionView) {
            ReminderSelectionView(remindersArray: $reminders, selectedItems: $selectedItems, isPresented: $showReminderSelectionView)
        }
    }
    
    private func startListening() {
        isListening = true
        voiceManager.startListening { result in
            DispatchQueue.main.async {
                self.isListening = false
                switch result {
                case .success(let text):
                    self.transcribedText += text + "\n"
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func stopListening() {
        isListening = false
        voiceManager.stopListening()
    }
    
    private func generateFromVoice() {
        isLoading = true
        // Directly use ReminderService here to maintain clarity and control over the state
        ReminderService().fetchReminders(ocrData: self.transcribedText) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let fetchedReminders):
                    // Convert fetched reminders to Reminder model and update the state
                    self.reminders = fetchedReminders.compactMap { dict -> Reminder? in
                        guard let title = dict["title"], let time = dict["time"] else { return nil }
                        return Reminder(title: title, dueDateComponentsAsString: time)
                    }
                    self.selectedItems = Array(repeating: true, count: self.reminders.count)
                    // Present the ReminderSelectionView
                    self.showReminderSelectionView = true
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}

struct UploadVoiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UploadVoiceView()
        }
    }
}
