//
//  ShopItem.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/18.
//

import Foundation

struct ShopItem {
    var title: String
    var detail: String
    
    ///need to be deprecated -> to item code
    var price: Int
    
    var questions: [String]
    
    var additionalImageLinks: [String]
    
    var bookImage: String
    
    var privateMode: Bool
    
    var hashtags: [String]
}
