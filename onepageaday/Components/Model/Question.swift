//
//  Question.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import Foundation
import PencilKit



//ios, android 구분 필요 있음.
struct Question:Codable {
    enum OS : Int,Codable{
        case iOS,Android
    }
    
    var index: Int
    var text: String
    
    var textViewDatas: [TextViewData]
    var imageViewDatas: [ImageViewData]
    var drawings: PKDrawing
    
    var os: OS
    
    var token: String
    
    
    init(index:Int, text:String, textViewDatas: [TextViewData]=[], imageViewDatas: [ImageViewData]=[], drawings: PKDrawing=PKDrawing(),os: Question.OS = .iOS) {
        self.index = index
        self.text = text
        
        self.imageViewDatas = imageViewDatas
        self.textViewDatas = textViewDatas
        self.drawings = drawings
        
        self.token = UUID().uuidString
        self.os = os
    }
}
