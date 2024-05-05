//
//  ContentView.swift
//  QuickReminder
//
//  Created by Xuan Xu on 2024/5/3.
//

// Updated ContentView.swift

import SwiftUI

struct UploadImageView: View {
    var selection = "👾"
    @State private var showImagePicker: Bool = false
    @State private var selectedImages: [UIImage] = [] // Update to hold multiple selected images
    @State private var ocrText: String = ""
    @State private var reminders: [Reminder] = [] // Array to store fetched reminders
    
    // Instances of ReminderService and ReminderManager
    private let reminderService = ReminderService()
    private let reminderManager = ReminderManager()
    private var reminderHelper: ReminderHelper {
        ReminderHelper(
            reminders: $reminders,
            selectedItems: $selectedItems,
            showReminderSelectionView: $showReminderSelectionView,
            selectedImages: selectedImages
        )
    }
    
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
                        
                            Button(action: 
                                    {
                                performOCR()
                            }) {
                                Text("Generate")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedImages.isEmpty ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .disabled(selectedImages.isEmpty)
                            }
                        
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImages: $selectedImages)
                    }
                    .sheet(isPresented: $showReminderSelectionView) {
                        ReminderSelectionView(remindersArray: $reminders, selectedItems: $selectedItems, isPresented: $showReminderSelectionView)
                    }
                }
                
    private func performOCR() {
        let ocrController = OCRController()
        
        // 递归函数，处理下一个图像
        func processNextImage(index: Int) {
            guard index < selectedImages.count else { // 检查是否已处理完所有图像
                reminderHelper.handleTextResult(text: ocrText) // 处理文本结果
                return
            }
            
            // 处理当前图像
            ocrController.recognizeText(from: selectedImages[index]) { result in
                switch result {
                case .success(let text):
                    ocrText += text + "\n" // 将文本添加到 ocrText 中
                    processNextImage(index: index + 1) // 处理下一个图像
                case .failure(let error):
                    print("Error: \(error)")
                    processNextImage(index: index + 1) // 处理下一个图像
                }
            }
        }
        
        // 开始处理第一个图像
        processNextImage(index: 0)
    }

                
            }
