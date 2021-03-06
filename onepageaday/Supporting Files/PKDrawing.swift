//
//  PKDrawing.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/17.
//

import Foundation
import PencilKit

//문자열로 그림 저장
extension PKDrawing {
    func base64EncodedString() -> String {
        return dataRepresentation().base64EncodedString()
    }
    
    enum DecodingError: Error {
        case decodingError
    }
    
    init(base64Encoded base64: String) throws {
        guard let data = Data(base64Encoded: base64) else {
            throw DecodingError.decodingError
        }
        try self.init(data: data)
    }
}
