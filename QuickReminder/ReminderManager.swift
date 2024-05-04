import Foundation
import EventKit

class ReminderManager {
    let eventStore = EKEventStore()

    func createReminders(from jsonArray: [[String: String]], selectedItems: [Bool]) {
        eventStore.requestFullAccessToReminders { (granted, error) in
            if granted && error == nil {
                // Check for available calendars
                let calendars = self.eventStore.calendars(for: .reminder)
                guard let calendar = calendars.first(where: { $0.allowsContentModifications }) else {
                    print("Error: No modifiable calendars available for reminders.")
                    return
                }
                
                for (index, reminderDict) in jsonArray.enumerated() {
                    if selectedItems[index], let time = reminderDict["time"], let title = reminderDict["title"] {
                        let reminder = EKReminder(eventStore: self.eventStore)
                        reminder.title = title
                        reminder.calendar = calendar // Set a specific calendar
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        if let date = dateFormatter.date(from: time) {
                            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                        }
                        
                        print(reminder)
                        
                        do {
                            try self.eventStore.save(reminder, commit: true)
                        } catch let saveError {
                            print("Error: Unable to save reminder. \(saveError)")
                        }
                    }
                }

            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
