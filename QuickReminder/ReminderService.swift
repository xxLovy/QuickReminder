//
//  ReminderService.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/3.
//

import Foundation

struct ReminderService {
    // Function to fetch reminders, returns dummy data
    func fetchReminders(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        // Dummy JSON array to simulate the data you might receive from a server
        let dummyData = [
            ["time": "2024-05-03 09:00:00", "title": "Morning Meeting"],
            ["time": "2024-05-03 12:00:00", "title": "Lunch with Team"],
            ["time": "2024-05-03 18:00:00", "title": "Evening Jog"]
        ]
        
        // Simulate a network request with a delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Return the dummy data after the delay
            DispatchQueue.main.async {
                completion(.success(dummyData))
            }
        }
    }
}
