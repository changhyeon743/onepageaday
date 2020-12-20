//
//  Question.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import Foundation
import PencilKit
import FirebaseFirestoreSwift



//ios, android 구분 필요 있음.
struct Question:Codable,Identifiable {
    enum OS : Int,Codable{
        case iOS,Android
    }
    
    
    @DocumentID var id: String? = UUID().uuidString
    
    
    var index: Int = 0
    var text: String = ""
    
    var textViewDatas: [TextViewData] = []
    var imageViewDatas: [ImageViewData] = []
    var drawings: String = ""
    
    var backGroundColor: String? = UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1).toHexString()
    
    var book: String = ""
    
    var os: OS = .iOS
    
    init(index: Int, text: String, book: String) {
        self.index = index
        self.text = text
        self.book = book
        self.textViewDatas = []
        self.imageViewDatas = []
        self.drawings = ""
        self.os = .iOS
    }
}
