//
//  File.swift
//  
//
//  Created by devonly on 2021/12/27.
//  
//

import Foundation
import SwiftUI

extension Text {
    public init<T: LosslessStringConvertible>(_ content: Optional<T>) {
        if let content = content {
            self.init(verbatim: String(content))
        } else {
            self.init(verbatim: "-")
        }
    }
}
