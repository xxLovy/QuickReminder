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
                    ekReminder.notes = reminder.notes
                    ekReminder.startDateComponents = reminder.startDateComponents
                    ekReminder.dueDateComponents = reminder.dueDateComponents
                    ekReminder.priority = reminder.priority
                    ekReminder.calendar = calendar

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
