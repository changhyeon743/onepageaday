//
//  OFV_ImageView.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/20.
//

import UIKit
import Kingfisher

class OFV_ImageView: AnimatedImageView {
    public var imageViewData: ImageViewData = ImageViewData(center: CGPoint.zero, angle: 0, scale: 1, imageURL: "")
    private var magnification:CGFloat = 1
    
    init(frame: CGRect,imageViewData: ImageViewData, magnification: CGFloat) {
        super.init(frame: frame)
        self.magnification = magnification
        self.layer.allowsEdgeAntialiasing = true // iOS7 and above.
        
        self.imageViewData = imageViewData
        //ADJUSTED!!
        
        //현재 좌표는 iPhone6
        self.center = CGPoint(x: imageViewData.center.x / magnification, y: imageViewData.center.y / magnification)
        
        self.transform = self.transform.scaledBy(x: imageViewData.scale / magnification, y: imageViewData.scale / magnification).rotated(by: imageViewData.angle)
        
        //API.giphyApi.getStillURL(from: imageViewData.imageURL)
        if let url = URL(string: imageViewData.imageURL) {
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url, options: [.transition(ImageTransition.fade(0.5)),.memoryCacheExpiration(.expired)])
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
