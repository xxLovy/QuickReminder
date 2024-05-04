//
//  ContentView.swift
//  QuickReminder
//
//  Created by Xuan Xu on 2024/5/3.
//

import SwiftUI

struct ContentView: View {
    var selection = "👾"
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var ocrText: String = ""
    @State private var remindersArray: [[String: String]] = [] // Array to store fetched reminders
    
    // Instances of ReminderService and ReminderManager
    private let reminderService = ReminderService()
    private let reminderManager = ReminderManager()
    
    // State property to track selected items
    @State private var selectedItems: [Bool] = []
    
    // State property to control reminder selection view presentation
    @State private var showReminderSelectionView: Bool = false
    
    var body: some View {
        VStack {
            // Display the selected emoji
            Text(selection)
                .font(.system(size: 150))
            
            // If an image is selected, display it
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()

                // Display OCR Result
                if !ocrText.isEmpty {
                    Text(ocrText)
                        .padding()
                }
            }
            
            // Button to upload image
            Button("Upload Image") {
                showImagePicker = true
            }
            
            // Button to perform OCR and handle reminders
            if selectedImage != nil {
                Button("Perform OCR") {
                    let ocrController = OCRController()
                    ocrController.recognizeText(from: selectedImage!) { result in
                        switch result {
                        case .success(let text):
                            self.ocrText = text
                            print("Recognized Text: \(text)")
                            
                            // Fetch dummy data from ReminderService
                            reminderService.fetchReminders { result in
                                switch result {
                                case .success(let fetchedReminders):
                                    // Update remindersArray and selectedItems
                                    self.remindersArray = fetchedReminders
                                    self.selectedItems = Array(repeating: true, count: fetchedReminders.count)
                                    
                                    // Show the reminder selection view
                                    self.showReminderSelectionView = true
                                case .failure(let error):
                                    print("Error fetching reminders: \(error)")
                                }
                            }
                            
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showReminderSelectionView) {
            ReminderSelectionView(remindersArray: $remindersArray, selectedItems: $selectedItems, isPresented: $showReminderSelectionView)
        }
    }
}
