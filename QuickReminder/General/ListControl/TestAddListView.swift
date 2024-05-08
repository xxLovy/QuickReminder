//
//  AddListView.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/6.
//

import SwiftUI

struct AddReminderListView: View {
    @State private var title: String = ""
    @State private var selectedColor: UIColor = .blue
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let colors: [UIColor] = [.blue, .red, .green, .orange]
    private var reminderListManager = ReminderListManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("List Details")) {
                    TextField("Title", text: $title)
                    
                    Picker("Color", selection: $selectedColor) {
                        ForEach(colors, id: \.self) { color in
                            Color(color).tag(color)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Button("Add") {
                    addReminderList()
                }
                .disabled(title.isEmpty)
            }
            .navigationTitle("Add Reminder List")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Reminder List"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func addReminderList() {
        let reminderList = ReminderList(title: title, color: selectedColor)
        reminderListManager.addReminderList(reminderList) { success, error in
            if success {
                alertMessage = "List added successfully."
            } else {
                alertMessage = "Failed to add list: \(error?.localizedDescription ?? "Unknown error")"
            }
            showingAlert = true
        }
    }
}

struct AddReminderListView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderListView()
    }
}
