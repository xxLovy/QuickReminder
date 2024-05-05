//
//  Types.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/5.
//

import Foundation

struct Reminder: Identifiable {
    let id = UUID()
    var title: String
    var startDateComponentsAsString: String?
    var priority: Int = 0 // 设置默认值为最低级
    var dueDateComponentsAsString: String?
    var notes: String?
    
    // 计算属性：将 startDateComponentsAsString 转换为 Date 格式
    var startDateComponents: DateComponents? {
        return dateFormat(dateString: startDateComponentsAsString)
    }
    
    // 计算属性：将 dueDateComponentsAsString 转换为 Date 格式
    var dueDateComponents: DateComponents? {
        return dateFormat(dateString: dueDateComponentsAsString) // 修改此处
    }
    
    func dateFormat(dateString: String?) -> DateComponents? { // 修改返回类型为可选的 DateComponents
        guard let dateString = dateString else { return nil } // 添加空值检查
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: dateString) {
            return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        }
        return nil // 添加返回空值的情况
    }
}
