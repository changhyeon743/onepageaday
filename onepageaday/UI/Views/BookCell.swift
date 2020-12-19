//
//  BookCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/15.
//

import UIKit
import SkeletonView

class BookCell: UICollectionViewCell{
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        //self.titleLabel.showAnimatedGradientSkeleton()
    }
}
