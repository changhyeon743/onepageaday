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
    
    var modifiedDate: Date?
    
    var index: Int = 0
    var text: String = ""
    
    var textViewDatas: [TextViewData] = []
    var imageViewDatas: [ImageViewData] = []
    var drawings: String = ""
    
    var backGroundColor: String? = Constant.Design.backGroundColors.randomElement() ?? defaultColor
    
    var privateMode: Bool = false
    var os: OS = .iOS
    
    init(index: Int, text: String,privateMode: Bool) {
        self.index = index
        self.text = text
        self.textViewDatas = []
        self.imageViewDatas = []
        self.drawings = ""
        self.privateMode = privateMode
        self.os = .iOS
    }
}
