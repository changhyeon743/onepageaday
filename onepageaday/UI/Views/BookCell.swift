//
//  BookCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/15.
//

import UIKit
import SkeletonView
import Then
import SnapKit

class BookCell: UICollectionViewCell{
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.titleLabel.showAnimatedGradientSkeleton()
        
        
        self.titleLabel.font = .cafe(size: 18)
        self.detailLabel.font = .cafe(size: 12)
        self.clipsToBounds = false
        
        
        let _ = UIView().then{
            $0.backgroundColor = .darkGray.withAlphaComponent(0.4)
            self.addSubview($0)
            self.sendSubviewToBack($0)
            $0.snp.makeConstraints{
                $0.width.height.equalToSuperview()
                $0.centerX.centerY.equalToSuperview().offset(8)
            }
        }
    }
}
