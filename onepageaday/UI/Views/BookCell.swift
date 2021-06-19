//
//  BookCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/15.
//

import UIKit
import SkeletonView

class BookCell: UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.titleLabel.showAnimatedGradientSkeleton()
        
        
        self.titleLabel.font = .cafe(size: 17)
        self.dateLabel.font = .cafe(size: 14)
    }
}
