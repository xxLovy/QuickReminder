//
//  ReminderSelectionView.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/4.
//
// ReminderSelectionView.swift

import SwiftUI

struct ReminderSelectionView: View {
    @Binding var remindersArray: [Reminder]
    @Binding var selectedItems: [Bool]
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Select Reminders to Add")
                .font(.title)
                .padding()
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach($remindersArray.indices, id: \.self) { index in
                        ReminderSelectionRow(reminder: $remindersArray[index], isSelected: $selectedItems[index])
                    }
                }
                .padding()
            }
            
            Button("Add Selected Reminders") {
                let reminderManager = ReminderManager()
                let selectedReminders = remindersArray.enumerated().compactMap { index, reminder in
                    selectedItems[index] ? reminder : nil
                }
                reminderManager.createReminders(from: selectedReminders )
                isPresented = false // Dismiss the ReminderSelectionView
            }
            .padding()
        }
        .onDisappear {
            // 重置 remindersArray 和 selectedItems
            remindersArray = []
            selectedItems = []
        }
        
    }
}

struct ReminderSelectionRow: View {
    @Binding var reminder: Reminder
    @Binding var isSelected: Bool
    @State private var selectedDate: Date = Date() // State to hold the selected date
    @State private var initialDate: Date = Date() // Store the initial state of the reminder

    init(reminder: Binding<Reminder>, isSelected: Binding<Bool>) {
        self._reminder = reminder
        self._isSelected = isSelected
        self._selectedDate = State(initialValue: Date())
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Title", text: $reminder.title)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .onTapGesture {
                        isSelected.toggle()
                    }
            }
            .padding()
            
            DatePicker(
                            "Select Time",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .onChange(of: selectedDate) { newValue in
                            // Update reminder.time when selectedDate changes
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            reminder.dueDateComponentsAsString = dateFormatter.string(from: newValue)
                        }
                        .onAppear {
                            // Initialize the selectedDate and initialDate from reminder.time
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            if let date = dateFormatter.date(from: reminder.dueDateComponentsAsString ?? "") {
                                selectedDate = date
                                initialDate = date // Store the initial date
                            }
                        }
                        
                        Button(action: {
                            // Reset the selectedDate to the initial date
                            selectedDate = initialDate
                        }, label: {
                            Text("Restore to default time")
                                .foregroundColor(.red)
                        })
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
    }
    
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
}
