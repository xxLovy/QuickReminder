//
//  ListControl.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/6.
//

import Foundation
import EventKit
import UIKit

// ReminderList class to represent a list with necessary attributes
class ReminderList {
    var title: String
    var color: UIColor?
    
    init(title: String, color: UIColor? = nil) {
        self.title = title
        self.color = color
    }
}

// ReminderListManager class to manage reminder lists
class ReminderListManager {
    private let eventStore = EKEventStore()
    
    // Request access to the user's reminders
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .reminder) { granted, error in
            completion(granted, error)
        }
    }
    
    // Add a new list to the Reminders app
    func addReminderList(_ reminderList: ReminderList, completion: @escaping (Bool, Error?) -> Void) {
        requestAccess { [weak self] (granted, error) in
            guard granted, error == nil else {
                completion(false, error)
                return
            }
            
            let calendar = EKCalendar(for: .reminder, eventStore: self?.eventStore ?? EKEventStore())
            calendar.title = reminderList.title
            calendar.cgColor = reminderList.color?.cgColor ?? UIColor.blue.cgColor
            calendar.source = self?.eventStore.defaultCalendarForNewReminders()?.source
            
            do {
                try self?.eventStore.saveCalendar(calendar, commit: true)
                completion(true, nil)
            } catch let error {
                completion(false, error)
            }
        }
    }
}
