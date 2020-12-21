//
//  TextViewData.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import Foundation
import UIKit

enum TextAlignment: Int,Codable {
    case left, middle, right
}

struct TextViewData: Codable {
    var center:CGPoint
    var angle:CGFloat
    var scale:CGFloat
    
    var alignment: TextAlignment
    
    var textColor: String
    
    var text:String
    
    var token:String
    
    init(center: CGPoint, angle:CGFloat, scale: CGFloat, text: String,textColor: String="000000", token:String="") {
        self.center = center
        self.angle = angle
        self.scale = scale
        self.textColor = textColor
        self.text = text
        self.alignment = .middle
        self.token = UUID().uuidString
    }
}


struct ImageViewData: Codable {
    var center:CGPoint
    var angle:CGFloat
    var scale:CGFloat
    
    var imageURL:String
    
    var token:String
    
    init(center: CGPoint, angle:CGFloat, scale: CGFloat, imageURL: String, token:String="") {
        self.center = center
        self.angle = angle
        self.scale = scale
        self.imageURL = imageURL
        if (token.isEmpty) {
            self.token = UUID().uuidString
        } else {
            self.token = token
        }

    }
    
}
