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
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.titleLabel.showAnimatedGradientSkeleton()
        self.layer.cornerRadius = 4.0
        self.clipsToBounds = true
    }
}
