//
//  Helper.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/4.
//

import Foundation
import SwiftUI

struct ReminderHelper {
    var reminders: Binding<[Reminder]>
    var selectedItems: Binding<[Bool]>
    var showReminderSelectionView: Binding<Bool>
    var selectedImages: [UIImage]
    
    let reminderService = ReminderService()
    
    // Function to handle the result of text processing
    func handleTextResult(text: String) {
        reminderService.fetchReminders(ocrData: text) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedReminders):
                    self.updateReminders(with: fetchedReminders)
                case .failure(let error):
                    print("Error fetching reminders: \(error)")
                }
            }
        }
    }
    
    // Function to update the reminders array with the fetched reminders
    func updateReminders(with fetchedReminders: [[String: String]]) {
        let newReminders = fetchedReminders.compactMap { dict -> Reminder? in
            guard let title = dict["title"], let time = dict["time"] else { return nil }
            return Reminder(title: title, dueDateComponentsAsString: time)
        }
        reminders.wrappedValue += newReminders
        selectedItems.wrappedValue += Array(repeating: true, count: newReminders.count)
        
        if let lastImage = selectedImages.last, let currentImage = selectedImages.first, lastImage == currentImage {
            showReminderSelectionView.wrappedValue = true
        }
    }
}
