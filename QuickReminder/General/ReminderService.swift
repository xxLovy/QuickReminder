//
//  ReminderService.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/3.
//

import Foundation

struct ReminderService {
    // Function to fetch reminders, returns dummy data
    func fetchReminders(ocrData: String, completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        // Define the endpoint URL
        guard let url = URL(string: "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/llama_3_8b?access_token=24.b4f3ba047f4ff9b0ed347521558bf8f9.2592000.1717382586.282335-66708760") else {
            completion(.failure(NSError(domain: "ReminderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let prompt = Prompt()
        let textToProcess = ocrData
        let promptText = prompt.generatePrompt(with: textToProcess)
//        print(promptText)
        
        // Prepare the request body
        let requestBody: [String: Any] = [
            "messages": [
                ["role": "user", "content": promptText]
            ]
        ]
        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "ReminderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode request body"])))
            return
        }
        request.httpBody = requestBodyData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "ReminderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
            
            // Convert data to a String and print it
            if let dataString = String(data: data, encoding: .utf8) {
                print("Received data: \(dataString)")
            } else {
                print("Received data couldn't be converted to String")
            }

                // Attempt to parse the JSON data
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let resultString = json["result"] as? String {
                        // Remove the triple backticks and correct the JSON format
                        let cleanedResultString = resultString
                            .trimmingCharacters(in: CharacterSet(charactersIn: "`"))
                            .replacingOccurrences(of: "[[", with: "[{")
                            .replacingOccurrences(of: "]]", with: "}]")
                            .replacingOccurrences(of: "[\"", with: "{\"")
                            .replacingOccurrences(of: "\"]", with: "\"}")
                            .replacingOccurrences(of: "\", \"", with: "\",\"")

                        // Now parse the cleaned JSON string into an array of dictionaries
                        if let resultData = cleanedResultString.data(using: .utf8),
                           let result = try JSONSerialization.jsonObject(with: resultData, options: []) as? [[String: String]] {
                            completion(.success(result))
                        } else {
                            completion(.failure(NSError(domain: "ReminderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse reminders from result string"])))
                        }
                    } else {
                        completion(.failure(NSError(domain: "ReminderService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
    }
}
