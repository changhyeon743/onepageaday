//
//  OFVTextView.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/20.
//

import UIKit

//Use UILabel instead of TextView
class OFV_TextView: UILabel {
    
    public var textViewData: TextViewData = TextViewData(center: CGPoint.zero, angle: 0, scale: 1, text: "")
    private var magnification:CGFloat = 1
    
    init(frame: CGRect, textViewData: TextViewData, magnification: CGFloat) {
        super.init(frame: frame)
        self.magnification = magnification
        
        self.layer.allowsEdgeAntialiasing = true // iOS7 and above.
        self.textViewData = textViewData
//        self.adjustsFontSizeToFitWidth = true
        self.numberOfLines = 0
        self.backgroundColor = .clear
        self.font = Constant.Design.textViewFont
       
        //TextAlignment ( 변수 사용할 게 많아서 마지막에 호출 )
        setAlignment()
        setColor()
        
        
        //First Alignment Last text!!
        self.text = textViewData.text
        self.sizeToFit()
        self.layoutIfNeeded()
        
        self.center = CGPoint(x: textViewData.center.x / magnification, y: textViewData.center.y / magnification)

        self.transform = self.transform.scaledBy(x: textViewData.scale / magnification, y: textViewData.scale / magnification).rotated(by: textViewData.angle)
        
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
