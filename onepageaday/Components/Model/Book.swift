//
//  Page.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import Foundation
import UIKit

struct Book: Codable {
    var title: String
    var questionTokens: [String]
    
    var token: String
    
    var currentIndex: Int
    
    init(title:String, questionTokens:[String], currentIndex:Int=0) {
        self.title = title
        self.questionTokens = questionTokens
        self.currentIndex = currentIndex
        self.token = UUID().uuidString
    }
}
