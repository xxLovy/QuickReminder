//
//  HomePage.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/4.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        VStack {
            // The top two-thirds of the screen with an explanatory text box
            Text("Welcome to the QuickReminder App!\nHere you can create reminders quickly using text, images, or even your voice.")
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .multilineTextAlignment(.center)
                .font(.title2)
            
            // The bottom third of the screen with three buttons
            HStack {
                // Text button
                Button(action: {
                    // Action for Text button
                }) {
                    
                    NavigationLink(destination: UploadTextView()){
                    Text("Text")
                        .frame(maxWidth: .infinity)
                }
                }
                
                // Image button
                NavigationLink(destination: UploadImageView()) {
                    Text("Image")
                        .frame(maxWidth: .infinity)
                }
                
                // Voice button
                NavigationLink(destination: UploadVoiceView()) {
                    Text("Voice")
                        .frame(maxWidth: .infinity)
                }
                
//                // Test add list functionality
//                NavigationLink(destination: AddReminderListView()) {
//                    Text("Add List")
//                        .frame(maxWidth: .infinity)
//                }

                
            }
            .frame(maxHeight: .infinity / 3)
        }
        .padding()
        .navigationTitle("Home")
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomePage()
        }
    }
}

