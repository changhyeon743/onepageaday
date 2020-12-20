//
//  Date.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/19.
//

import Foundation

//책에 나타낼 날짜
extension Date {
    func toString(format: String = "yyyy-MM-dd HH:mm") -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.dateFormat = format
            return formatter.string(from: self)
        }
}
