//
//  FirebaseAPI.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/17.
//

import Foundation
import SwiftyJSON
import Firebase

class FirebaseAPI {
    //트렌드
    func fetchBooks(completion:@escaping([Book])->Void) {
        Firestore.firestore().collection("books").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let query = querySnapshot {
                    
                    let books = query.documents.compactMap { (book) -> Book? in
                        let title = book["title"] as? String ?? ""
                        let detail = book["detail"] as? String ?? ""
                        let currentIndex = book["currentIndex"] as? Int ?? 0
                        
                        return Book(id: book.documentID, title: title, detail: detail, currentIndex: currentIndex)
                    }
                    completion(books)
                }
            }
        }
    }
    
}
