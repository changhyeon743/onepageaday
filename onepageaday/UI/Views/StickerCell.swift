//
//  GifCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/21.
//

import Foundation
import UIKit
import SkeletonView

class StickerCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.titleLabel.showAnimatedGradientSkeleton()
    }
    
}
