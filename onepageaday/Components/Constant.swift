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
        static let imageViewWidth : CGFloat = 100
        static let imageViewHeight: CGFloat = 100
    }
}
