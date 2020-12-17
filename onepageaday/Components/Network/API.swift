//
//  API.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import Foundation

class API {
    static var giphyApi = GiphyAPI()
    
    let emoji = "https://emojicdn.elk.sh/%F0%9F%A4%A9?style=apple"
    
    //question 전부를 메모리에 할당하는 것도 미친짓이라는 걸 알아야함.
    //임시방편. Book 이라는 최상위 클래스 존재해야함.
    static var currentQuestions: [Question] = [Question(index: 0, text: "눈을 감으면 무슨 생각이 나나요?"),
                                        Question(index: 1, text: "혼자 있으면 무얼 하나요?"),
                                        Question(index: 2, text: "아무것도 하지 않고 5분만 멈추어볼까요?"),
                                        Question(index: 3, text: "오늘은 __________날"),
                                        Question(index: 4, text: "오늘은 __________않는 날"),
                                        Question(index: 5, text: "오늘 점심으로 무엇을 먹었나요?"),
                                        Question(index: 6, text: "오늘은 손을 몇 번 씻었을까요?"),
                                        Question(index: 7, text: "오늘 날씨는 어떤가요?"),
                                        Question(index: 8, text: "숲에 무엇이 있나요?"),
                                       ]
    
    static var books: [Book] = [
        Book(title: "기본적인 매일력", questionTokens: ["A6FCAD7D-9885-4D06-9E5F-472304435006", "E247B34A-08F0-4EBB-9943-F01AE41913B3", "0123E91A-99F9-48F8-9D63-B20A56630FF3", "5A723301-D4D3-462F-A835-19452159955F", "684020F7-E4CF-4519-B4E8-CA86C92EB2D6", "73329CEE-40FA-47EE-B7B1-3D2E37CA8238", "30821A5D-ADDC-476E-BC22-13B639096989", "7E290F3E-E5FC-46D0-A079-E6CB5E2DBCED"]),
        Book(title: "기본적인 매일력2", questionTokens: ["A6FCAD7D-9885-4D06-9E5F-472304435006", "E247B34A-08F0-4EBB-9943-F01AE41913B3",]),
        Book(title: "기본적인 매일력3", questionTokens: ["A6FCAD7D-9885-4D06-9E5F-472304435006"])
             
    ]
}
