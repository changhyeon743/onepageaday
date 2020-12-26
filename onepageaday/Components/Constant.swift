//
//  Constant.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/25.
//

import Foundation
import UIKit

struct Constant {
    struct OFV {
        ///배율 2 -> 1/2배
        static let magnification : CGFloat = 2
        ///작은 셀 크기
        static let cellWidth : CGFloat = Device.base / magnification
        ///작은 셀 크기
        static let cellHeight : CGFloat = Device.baseHeight / magnification
    }
    
    struct Design {
        static let textViewHeight : CGFloat = 100
        static let textViewFont: UIFont = UIFont.systemFont(ofSize: 40)
        static let imageViewWidth : CGFloat = 100
        static let imageViewHeight: CGFloat = 100
        
        static let backGroundColors: [String] = [  "1abc9c","2ecc71","3498db","9b59b6","34495e","16a085","27ae60","2980b9","8e44ad","2c3e50","f1c40f","e67e22","e74c3c","ecf0f1","95a5a6","f39c12","d35400","c0392b","bdc3c7","7f8c8d"]
        static let textColors: [String] = ["ffffff","e74c3c","#e67e22","#f1c40f","#2ecc71","#3498db","#9b59b6","000000"]
    }
}
