//
//  Prompt.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/4.
//


import Foundation

struct Prompt {
    let today: Date
    
    init() {
        self.today = Date()
    }
    
    func generatePrompt(with text: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let formattedToday = dateFormatter.string(from: today)
        
        return """
        Your task is to generate a JSON format text to help me process my text for helping me quickly add reminders to my Reminder app on my iPhone. Take time as keys and incident as values. You can presume the time that the conversion refers to and generate the time accordingly. Here are some steps that you might think is useful:
         - First, you need to use comma to make the text as a whole.
         - Second, use the "Date for Today" I provide below as today, presume the time the text mentions. If there is an incident before or after the text that you can refer I want to do something at this time. Then you can generate ["time": "things I want to do"]. And add it to the list that you want to return. If there is not any incidents before or after the text, you don't have to generate anything, just skip that time.
         - Third, repeat Second till all times in the times are processed.

        Here is the format that you want to return:
        [
                    ["time": "2024-05-03 09:00:00", "title": "Morning Meeting"],
                    ["time": "2024-05-03 12:00:00", "title": "Lunch with Team"],
                    ["time": "2024-05-03 18:00:00", "title": "Evening Jog"]
                ]


        Summarize the text below, delimited by triple backticks. You must use the language of the Text, for example: if Text is in Chinese, the fields in the title must be in Chinese. Note: Except for the JSON, do not return any other content!
        Text: ```\(text)```
        Date for Today: ```\(formattedToday)```
        """
    }
}
