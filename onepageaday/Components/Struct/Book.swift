//
//  Page.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

struct Book: Codable,Identifiable {
    @DocumentID var id: String? = UUID().uuidString
    var title: String
    var detail: String
    var author: String
    var currentIndex: Int
    
    var backGroundImage: String?
    
    var createDate: Date
    var modifiedDate: Date
    
}
