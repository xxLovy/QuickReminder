//
//  ContentView.swift
//  QuickReminder
//
//  Created by Xuan Xu on 2024/5/3.
//

// Updated ContentView.swift
import SwiftUI
struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var time: String
}

struct ContentView: View {
    var selection = "👾"
    @State private var showImagePicker: Bool = false
    @State private var selectedImages: [UIImage] = [] // Update to hold multiple selected images
    @State private var ocrText: String = ""
    @State private var reminders: [Reminder] = [] // Array to store fetched reminders
    
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
            
            // Display selected images
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedImages, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .padding()
                    }
                }
            }
            
            // Button to upload images
            Button("Upload Images") {
                showImagePicker = true
            }
            
            // Button to perform OCR and handle reminders
            if !selectedImages.isEmpty {
                Button("Perform OCR") {
                    let ocrController = OCRController()
                    // Loop through each selected image
                    for image in selectedImages {
                        ocrController.recognizeText(from: image) { result in
                            switch result {
                            case .success(let text):
                                self.ocrText += text + "\n" // Concatenate the recognized text
                                print("Recognized Text: \(text)")
                                
                                // Fetch dummy data from ReminderService
                                reminderService.fetchReminders(ocrData: self.ocrText) { result in
                                    switch result {
                                    case .success(let fetchedReminders):
                                        // Update remindersArray and selectedItems
                                        let newReminders = fetchedReminders.compactMap { dict -> Reminder? in
                                                                guard let title = dict["title"], let time = dict["time"] else { return nil }
                                                                return Reminder(title: title, time: time)
                                                            }
                                                            self.reminders += newReminders
                                                            self.selectedItems += Array(repeating: true, count: newReminders.count)
                                                            
                                        
                                        // Show the reminder selection view after processing all images
                                        if self.selectedImages.last == image {
                                            self.showReminderSelectionView = true
                                        }
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
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .sheet(isPresented: $showReminderSelectionView) {
            ReminderSelectionView(remindersArray: $reminders, selectedItems: $selectedItems, isPresented: $showReminderSelectionView)
        }
    }
}
