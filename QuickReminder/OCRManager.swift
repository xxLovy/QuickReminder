//
//  OCRManager.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/3.
//

import Foundation
import Vision
import UIKit

struct OCRManager {
    func performOCR(on image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // 创建一个新的VNImageRequestHandler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // 创建一个VNRecognizeTextRequest
        let request = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                completion(nil)
                return
            }
            
            // 从请求结果获取VNRecognizedTextObservation对象
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // 从观察结果中提取最可能的字符串
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            // 连接字符串
            let fullText = recognizedStrings.joined(separator: "\n")
            completion(fullText)
        }
        
        // 执行文本识别请求
        do {
            try handler.perform([request])
        } catch {
            completion(nil)
        }
    }
}
