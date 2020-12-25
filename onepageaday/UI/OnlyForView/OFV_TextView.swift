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
        
        
        self.center = CGPoint(x: textViewData.center.x / Constant.OFV.magnification, y: textViewData.center.y / Constant.OFV.magnification)

        self.transform = self.transform.scaledBy(x: textViewData.scale / Constant.OFV.magnification, y: textViewData.scale / Constant.OFV.magnification).rotated(by: textViewData.angle)
        
        self.backgroundColor = .gray
        self.font = UIFont.systemFont(ofSize: 40 / Constant.OFV.magnification)
       
        //TextAlignment ( 변수 사용할 게 많아서 마지막에 호출 )
        setAlignment()
        setColor()
        self.layoutIfNeeded()
        
        //First Alignment Last text!!
        self.text = textViewData.text
        
    }
    
    
    
    func setColor() {
        self.textColor = UIColor(textViewData.textColor)
    }
    //addsubview 이후에 해야됨!
    
    func setAlignment() {
        self.textAlignment = NSTextAlignment.init(rawValue: textViewData.alignment.rawValue) ?? .center
        print("\(self.textViewData.text) / \(self.textAlignment.rawValue)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
