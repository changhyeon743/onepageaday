//
//  Toast.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/20.
//

import Foundation
import UIKit

//Toast Message
extension UIViewController {
    func showToast(text: String) {
        
        let label = UILabel(frame: CGRect(x: self.view.bounds.width/2-65, y: self.view.bounds.height - 25-150, width: 130, height: 30))
        
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        
        self.view.addSubview(label)
        
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 7
        label.clipsToBounds = true
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
            label.alpha = 0
        } completion: { (complete) in
            label.removeFromSuperview()
        }
        
    }
}
