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
    var id: String
    var detail: String
    var currentIndex: Int
    
    init(id:String=UUID().uuidString, title:String,detail:String, currentIndex:Int=0) {
        self.title = title
        self.detail = detail
        self.currentIndex = currentIndex
        self.id = id
    }
}
