//
//  ReminderManager.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/4.
//


import Foundation
import EventKit

class ReminderManager {
    let eventStore = EKEventStore()

    func createReminders(from reminders: [Reminder]) {
        eventStore.requestFullAccessToReminders { (granted, error) in
            if granted && error == nil {
                let calendars = self.eventStore.calendars(for: .reminder)
                guard let calendar = calendars.first(where: { $0.allowsContentModifications }) else {
                    print("Error: No modifiable calendars available for reminders.")
                    return
                }
                
                reminders.forEach { reminder in
                    let ekReminder = EKReminder(eventStore: self.eventStore)
                    ekReminder.title = reminder.title
                    ekReminder.calendar = calendar
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let date = dateFormatter.date(from: reminder.time) {
                        ekReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                    }
                    
                    do {
                        try self.eventStore.save(ekReminder, commit: true)
                    } catch let saveError {
                        print("Error: Unable to save reminder. \(saveError)")
                    }
                }
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
