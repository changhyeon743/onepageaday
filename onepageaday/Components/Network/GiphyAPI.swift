//
//  GiphyAPI.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import Foundation
import Alamofire
import SwiftyJSON

class GiphyAPI {
    let api_key = "faIsfUAcOV93GtYZma2AmZndLSkJar5D"
    
    //트렌드
    func getTrendContents(completion:@escaping(JSON)->Void) {
        let parameters = [
            "api_key" : api_key,
            "limit" : "25"
        ]
            
        Alamofire.request("https://api.giphy.com/v1/stickers/trending",method:.get,parameters:parameters,encoding:URLEncoding.queryString)
                .responseJSON(completionHandler: { (response) in
                    //1. JSON 변환
                    if let value = response.result.value,response.result.isSuccess {
                        completion(JSON(value))
                    }
                })
        }
    
}
