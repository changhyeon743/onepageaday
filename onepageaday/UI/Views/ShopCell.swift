//
//  ShopCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import UIKit

class ShopCell: UITableViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        titleLabel.font = .cafe(size: titleLabel.font.pointSize)
//        detailLabel.font = .cafe(size: detailLabel.font.pointSize)
        
        itemImageView.contentMode = .scaleAspectFill
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
