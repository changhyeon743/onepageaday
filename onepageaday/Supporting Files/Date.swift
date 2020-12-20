//
//  Date.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/19.
//

import Foundation
extension Date {
    func toString(format: String = "yyyy-MM-dd HH:mm") -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.dateFormat = format
            return formatter.string(from: self)
        }
}
