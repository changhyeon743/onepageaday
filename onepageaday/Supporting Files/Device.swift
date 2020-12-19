//
//  Device.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/19.
//

import Foundation
import UIKit

class Device {
  // Base width in point, use iPhone 6
  static let base: CGFloat = 768
    static let baseHeight:CGFloat = 1024

  static var ratio: CGFloat {
    return UIScreen.main.bounds.width / base
  }
    
    static var ratioHeight: CGFloat {
        return UIScreen.main.bounds.height / baseHeight
    }
}

extension CGFloat {

  var adjusted: CGFloat {
    return self * Device.ratio
  }
    var adjustedHeight: CGFloat {
        return self * Device.ratioHeight
    }
}

extension Double {

  var adjusted: CGFloat {
    return CGFloat(self) * Device.ratio
  }
    var adjustedHeight: CGFloat {
        return CGFloat(self) * Device.ratioHeight
    }
}

extension Int {

  var adjusted: CGFloat {
    return CGFloat(self) * Device.ratio
  }
    var adjustedHeight: CGFloat {
        return CGFloat(self) * Device.ratioHeight
    }
}
