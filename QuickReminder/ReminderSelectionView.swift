//
//  ReminderSelectionView.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/4.
//

import SwiftUI

struct ReminderSelectionView: View {
    @Binding var remindersArray: [[String: String]]
    @Binding var selectedItems: [Bool]
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Select Reminders to Add")
                .font(.title)
                .padding()
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(remindersArray.indices, id: \.self) { index in
                        ReminderSelectionRow(reminder: remindersArray[index], isSelected: $selectedItems[index])
                    }
                }
                .padding()
            }
            
            Button("Add Selected Reminders") {
                let reminderManager = ReminderManager()
                reminderManager.createReminders(from: remindersArray, selectedItems: selectedItems)
                isPresented = false // Dismiss the ReminderSelectionView
            }
            .padding()
        }
        .onAppear {
            print("ReminderSelectionView appeared.")
            print("remindersArray: \(remindersArray)")
            print("selectedItems: \(selectedItems)")
        }
    }
}

struct ReminderSelectionRow: View {
    let reminder: [String: String]
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(reminder["title"] ?? "")
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
                .onTapGesture {
                    isSelected.toggle()
                }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}
