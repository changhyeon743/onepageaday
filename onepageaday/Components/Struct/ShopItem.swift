//
//  ShopItem.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/18.
//

import Foundation
import SwiftyJSON

struct ShopItem {
    var title: String
    var subTitle: String
    var detail: String
    
    ///need to be deprecated -> to item code
    var price: Int
    
    var questions: [String]
    
    var additionalImageLinks: [String]
    
    var bookImage: String
    
    var privateMode: Bool
    
    static func mapping(json:JSON) -> ShopItem {
        
        return ShopItem(title: json["title"].stringValue,
                        subTitle: json["subTitle"].stringValue,
                        detail: json["detail"].stringValue,
                        price: json["price"].intValue,
                        questions: json["questions"].arrayValue.map{$0.stringValue},
                        additionalImageLinks: json["additionalImageLinks"].arrayValue.map{$0.stringValue},
                        bookImage: json["bookImage"].stringValue,
                        privateMode: json["privateMode"].boolValue)
        
    }
}
