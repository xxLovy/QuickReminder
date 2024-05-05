//
//  OCRController.swift
//  QuickReminder
//
//  Created by 许璇 on 2024/5/3.
//

import Vision
import UIKit

class OCRController {
  
    // 处理并返回识别结果。我们使用一个completion闭包来异步返回结果或错误。
    func recognizeText(from image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "OCRController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert UIImage to CGImage."])))
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(NSError(domain: "OCRController", code: -1, userInfo: [NSLocalizedDescriptionKey: "OCR failed with no results."])))
                return
            }
            
            let text = observations.compactMap({ $0.topCandidates(1).first?.string }).joined(separator: "\n")
            completion(.success(text))
        }
        
        do {
            try handler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
}
