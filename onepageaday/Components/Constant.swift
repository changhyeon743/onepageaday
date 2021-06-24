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
        static let magnification : CGFloat = 1
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
        
        static let backGroundColors: [String] = [
        "2796DA",
        "F1CF12",
        "3AB52B",
        "EC6934",
        "F5B2B2",
        "FAF8ED"]
        static let textColors: [String] = ["ffffff","e74c3c","#e67e22","#f1c40f","#2ecc71","#3498db","#9b59b6","000000"]
        
        static var mainBackGroundColor: UIColor {
            return UIColor.init("fbd6bf") ?? UIColor.white
        }
        
        static var mainTintColor: UIColor {
            return UIColor.black
        }
        
        static var darkGray: UIColor {
            return UIColor.darkGray
        }
    }
}
