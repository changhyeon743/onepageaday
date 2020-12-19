//
//  API.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import Foundation

class API {
    
    static var giphyApi = GiphyAPI()
    static var firebase = FirebaseAPI()
    
    let emoji = "https://emojicdn.elk.sh/%F0%9F%A4%A9?style=apple"
    
    //question 전부를 메모리에 할당하는 것도 미친짓이라는 걸 알아야함.
    //임시방편. Book 이라는 최상위 클래스 존재해야함.
    static var currentQuestions: [Question] = []
    
    static var books: [Book]?
}
