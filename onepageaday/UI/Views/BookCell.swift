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
        self.layer.cornerRadius = 12.0
        self.clipsToBounds = true
        
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
    }
}
