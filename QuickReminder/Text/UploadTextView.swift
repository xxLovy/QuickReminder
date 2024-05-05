//
//  UploadTextView.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/4.
//


import SwiftUI

struct UploadTextView: View {
    @State private var userInput: String = ""
    @State private var reminders: [Reminder] = [] // This will hold the fetched reminders
    @State private var selectedItems: [Bool] = [] // This will hold the selection state of reminders
    @State private var isLoading: Bool = false // To indicate loading state
    @State private var showAlert: Bool = false // To show an alert if needed
    @State private var alertMessage: String = "" // The message for the alert
    @State private var showReminderSelectionView: Bool = false // State to control the presentation of ReminderSelectionView

    var body: some View {
        VStack {
            // The top two-thirds of the screen with a large text input area
            TextEditor(text: $userInput)
                .frame(maxHeight: .infinity)
                .border(Color.gray, width: 1)
                .padding()

            // Generate button at the bottom
            Button(action: {
                handleText()
            }) {
                Text("Generate")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoading || userInput.isEmpty ? Color.gray : Color.blue) // 根据按钮是否被禁用设置背景色
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading || userInput.isEmpty)
            .padding()

            Spacer() // Pushes everything to the top
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationTitle("Upload Text")
        .sheet(isPresented: $showReminderSelectionView) {
            ReminderSelectionView(remindersArray: $reminders, selectedItems: $selectedItems, isPresented: $showReminderSelectionView)
        }
    }
    
    private func handleText() {
        isLoading = true
        // Directly use ReminderService here to maintain clarity and control over the state
        ReminderService().fetchReminders(ocrData: userInput) { result in
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

struct UploadTextView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UploadTextView()
        }
    }
}
