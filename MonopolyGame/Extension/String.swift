//
//  String.swift
//  MonopolyGame
//
//  Created by Mykhailo Dovhyi on 03.04.2025.
//

import Foundation

extension String {
    var number:Int? {
        if let match = self.range(of: "\\d+", options: .regularExpression) {
            let numberString = String(self[match])
            return Int(numberString)
        }
        return nil
    }
    
    func extractSubstring(key:String, key2:String) -> String? {
        let pattern = "<\(key)>(.*?)<\(key2)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) else {
            
                return nil
            }
            
            let range = NSRange(self.startIndex..<self.endIndex, in: self)
        if let match = regex.firstMatch(in: self, options: [], range: range) {
                
                let rangeStart = match.range(at: 1)
                if let swiftRange = Range(rangeStart, in: self) {
                    return String(self[swiftRange])
                }
            }
        
        return nil
    }
    
    func extractXML(key1:String, key2:String) -> [String:String] {
        let pattern = "<\(key1)>(.*?)</\(key1)>\\s*<\(key2)>(\\d+)</\(key2)>"
        let xmlString = self
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]) {
            let matches = regex.matches(in: xmlString, range: NSRange(xmlString.startIndex..., in: xmlString))
            
            var result: [String: String] = [:]
            
            for match in matches {
                if let range1 = Range(match.range(at: 1), in: xmlString),
                   let range2 = Range(match.range(at: 2), in: xmlString) {
                    let ingredient = String(xmlString[range1])
                    let calories = String(xmlString[range2])
                    result[ingredient] = calories
                }
            }
            
            return result
        } else {
            return [:]
        }
    }
}
