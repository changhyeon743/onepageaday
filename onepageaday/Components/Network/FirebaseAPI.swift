//
//  FirebaseAPI.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/17.
//

import Foundation
import SwiftyJSON
import Firebase
import FirebaseFirestoreSwift

class FirebaseAPI {
    
    private var db = Firestore.firestore()
    
    //트렌드
    func fetchBooks(with userID: String, completion:@escaping([Book])->Void) {
        db.collection("books").whereField("author", isEqualTo: userID).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let query = querySnapshot {
                    
                    let books = query.documents.compactMap { (book) -> Book? in
                        return try? book.data(as: Book.self)
                    }
                    completion(books)
                }
            }
        }
    }
    
    //1. Question 전부 fetch
    //2. Question 일부만 fetch
    //3. 실시간 fetch
    func fetchQuestion(with bookID: String ,completion:@escaping([Question])->Void){
        db
            .collection("questions")
            .whereField("book", isEqualTo: bookID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if let query = querySnapshot {
                    
                    let questions = query.documents.compactMap { (question) -> Question? in
                        do {
                            return try question.data(as: Question.self)
                        } catch {
                            print(error.localizedDescription)
                        }
                        return nil
                    }
                    completion(questions)
                }
            }
        }
    }
    
    func updateQuestion(question: Question?) {
        do {
            guard let id = question?.id else { return }
            try db.collection("questions").document(id).setData(from: question)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateBook(book: Book?) {
        do {
            guard let id = book?.id else { return }
            try db.collection("books").document(id).setData(from: book)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addBook(book: Book, question: [String],completion: @escaping()->Void) {
        //Book adding
        do {
            let bookId = try db.collection("books").addDocument(from: book).documentID
            var indexCount = -1
            try question.forEach({ (str) in
                indexCount+=1
                let _ = try db.collection("questions").addDocument(from: Question(index: indexCount,text: str, book: bookId ), completion: { (_) in
                    completion()
                })
            })
            
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func deleteBook(with bookID: String) {
        //cascade questions
        db.collection("questions")
            .whereField("book", isEqualTo: bookID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let query = querySnapshot else {return}
                query.documents.forEach { (document) in
                    self.db.collection("questions").document(document.documentID).delete()
                }
            }
        }
        
        //
        db.collection("books").document(bookID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            }
            else {
                print("Document successfully removed!")
            }
        }
    }
}
