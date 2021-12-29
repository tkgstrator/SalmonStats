//
//  String.swift
//  
//
//  Created by devonly on 2021/12/27.
//  
//

import Foundation

extension String {
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
    private func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else { return [] }
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
