//
//  OFV_ImageView.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/20.
//

import UIKit
import Kingfisher

class OFV_ImageView: UIImageView {
    public var imageViewData: ImageViewData = ImageViewData(center: CGPoint.zero, angle: 0, scale: 1, imageURL: "")
    
    init(frame: CGRect,imageViewData: ImageViewData) {
        super.init(frame: frame)
        self.layer.allowsEdgeAntialiasing = true // iOS7 and above.
        
        self.imageViewData = imageViewData
        //ADJUSTED!!
        
        //현재 좌표는 iPhone6
        self.center = CGPoint(x: imageViewData.center.x / Constant.OFV.magnification, y: imageViewData.center.y / Constant.OFV.magnification)
        
        self.transform = self.transform.scaledBy(x: imageViewData.scale / Constant.OFV.magnification, y: imageViewData.scale / Constant.OFV.magnification).rotated(by: imageViewData.angle)
        
        if let url = URL(string: API.giphyApi.getStillURL(from: imageViewData.imageURL)) {
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url, options: [.transition(ImageTransition.fade(0.5))])
            
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
