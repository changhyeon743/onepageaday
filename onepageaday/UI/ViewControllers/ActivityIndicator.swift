//
//  ActivityIndicator.swift
//  onepageaday
//
//  Created by 이창현 on 2021/06/23.
//

import Foundation
import UIKit


func makeActivityIndicator(center: CGPoint) -> UIActivityIndicatorView {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    activityIndicator.center = center
    activityIndicator.backgroundColor = .init(white: 0, alpha: 0.5)
    activityIndicator.layer.cornerRadius = 14
    activityIndicator.clipsToBounds = true
    activityIndicator.color = .white
    
    // Also show the indicator even when the animation is stopped.
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = .large
    // Start animation.
    activityIndicator.stopAnimating()
    return activityIndicator
}
