//
//  TextViewData.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import Foundation
import UIKit



struct TextViewData: Codable {
    var center:CGPoint
    var angle:CGFloat
    var scale:CGFloat
    
    var text:String
    
    var token:String
    
    init(center: CGPoint, angle:CGFloat, scale: CGFloat, text: String, token:String="") {
        self.center = center
        self.angle = angle
        self.scale = scale
        self.text = text
        self.token = UUID().uuidString
    }
}


struct ImageViewData: Codable {
    var center:CGPoint
    var angle:CGFloat
    var scale:CGFloat
    
    var imageURL:String
    
    var token:String
    
    init(center: CGPoint, angle:CGFloat, scale: CGFloat, imageURL: String) {
        self.center = center
        self.angle = angle
        self.scale = scale
        self.imageURL = imageURL
        self.token = UUID().uuidString

    }
    
}
