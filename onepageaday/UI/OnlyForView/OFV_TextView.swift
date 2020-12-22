//
//  OFVTextView.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/20.
//

import UIKit

class OFV_TextView: UITextView {
    
    public var textViewData: TextViewData = TextViewData(center: CGPoint.zero, angle: 0, scale: 1, text: "")
    
    init(frame: CGRect, textContainer: NSTextContainer?, textViewData: TextViewData) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.layer.allowsEdgeAntialiasing = true // iOS7 and above.
        self.isScrollEnabled = false
        
        self.textViewData = textViewData
        self.text = textViewData.text
        self.center = textViewData.center
        self.transform = self.transform.scaledBy(x: textViewData.scale, y: textViewData.scale).rotated(by: textViewData.angle)
        
        setColor()
        self.backgroundColor = .none
        self.font = UIFont.systemFont(ofSize: 40)
        setAlignment()
        
    }
    
    func setColor() {
        self.textColor = UIColor(textViewData.textColor)
    }
    
    func setAlignment() {
        self.textAlignment = NSTextAlignment.init(rawValue: textViewData.alignment.rawValue) ?? .center
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
