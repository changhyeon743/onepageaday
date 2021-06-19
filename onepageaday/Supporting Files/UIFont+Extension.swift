//
//  UIFont+Extension.swift
//  onepageaday
//
//  Created by 이창현 on 2021/06/19.
//

import Foundation
import UIKit

public extension UIFont {
    
//    enum Family: String {
//        case Bold, Medium, Regular
//    }
    
    static func cafe(size: CGFloat = 10) -> UIFont {
        return UIFont(name: "Cafe24SsurroundAir", size: size) ?? .systemFont(ofSize: size)
    }
}
