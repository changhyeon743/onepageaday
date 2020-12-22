//
//  GiphyAPI.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import Foundation
import Alamofire
import SwiftyJSON
import Kingfisher

enum GiphyMode: Int {
    case sticker, gif
}

class GiphyAPI {
    let api_key = "faIsfUAcOV93GtYZma2AmZndLSkJar5D"
    init() {
        KingfisherManager.shared.downloader.downloadTimeout = 60
    }
    
    
    func getStillURL(from url: String) -> String{
        var complete_url = url
        if let dotRange = url.range(of: ".gif") {
            complete_url.removeSubrange(dotRange.lowerBound..<complete_url.endIndex)
            complete_url.append("_s.gif")
        }
        return complete_url
    }
    
    //트렌드
    func getTrendContents(mode:GiphyMode ,completion:@escaping(JSON)->Void) {
        let parameters = [
            "api_key" : api_key,
            "limit" : "9"
        ]
        
        var url = "https://api.giphy.com/v1/stickers/trending"
        if (mode == .gif) {
            url = "https://api.giphy.com/v1/gifs/trending"
        }
            
        Alamofire.request(url,method:.get,parameters:parameters,encoding:URLEncoding.queryString)
                .responseJSON(completionHandler: { (response) in
                    //1. JSON 변환
                    if let value = response.result.value,response.result.isSuccess {
                        completion(JSON(value))
                    }
                })
        }
    
    func search(with q: String, mode: GiphyMode, completion: @escaping(JSON)->Void) {
        
        let parameters = [
            "api_key" : api_key,
            "q" : q,
            "limit": "9"
        ]
        
        var url = "https://api.giphy.com/v1/stickers/search"
        if (mode == .gif) {
            url = "https://api.giphy.com/v1/gifs/search"
        }
        
        Alamofire.request(url,method:.get,parameters:parameters,encoding:URLEncoding.queryString)
            .responseJSON(completionHandler: { (response) in
                //1. JSON 변환
                if let value = response.result.value,response.result.isSuccess {
                    completion(JSON(value))
                }
            })
    }
    
}
