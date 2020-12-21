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
import FirebaseStorage

class FirebaseAPI {
    
    func isFireBaseStorageLink(url: String) -> Bool {
        return url.starts(with: "https://firebasestorage.googleapis.com")
    }
    
    private var db = Firestore.firestore()
    private var storageRef = Storage.storage().reference()
    
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
            .collection("books/\(bookID)/questions")
            .order(by: "index")
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
    
    func updateQuestion(question: Question?,bookID:String?) {
        
        var newQuestion = question
        newQuestion?.modifiedDate = Date()
        do {
            guard let id = bookID else { return }
            try db.collection("books/\(bookID)/questions").document(id).setData(from: newQuestion)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateBook(book: Book?) {
        do {
            guard let id = book?.id else { return }
            try db.collection("books").document(id).setData(from: book)
            if let index = API.books?.firstIndex(where: {$0.id == book?.id}), let book = book {
                API.books?[index] = book
            }
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
                let _ = try db.collection("books/\(bookId)/questions").addDocument(from: Question(index: indexCount,text: str ))
            })
            completion()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func deleteBook(with bookID: String) {
        //cascade images
        
        //cascade questions
        db.collection("books/\(bookID)/questions")
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let query = querySnapshot else {return}
                query.documents.forEach { (document) in
                    self.db.collection("books/\(bookID)/questions").document(document.documentID).delete()
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
    
    //삭제되는 경우는 사용자 드래그, and 책 통째로 삭제!
    //https://fomaios.tistory.com/entry/Swift-Storage%EC%97%90%EC%84%9C-%EC%9D%B4%EB%AF%B8%EC%A7%80-%EC%97%85%EB%A1%9C%EB%93%9C-%EB%B0%8F-%EB%8B%A4%EC%9A%B4%EB%A1%9C%EB%93%9C%ED%95%98%EA%B8%B0
    func uploadImage(image:UIImage, token: String, completion: @escaping((String)->Void)) {
        let data = image.jpegData(compressionQuality: 0.2)!
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
            
        let storeImage = storageRef.child("images").child(token)
        storeImage.putData(data, metadata: metadata) { (metadata, err) in
            if let error = err {
                print(error.localizedDescription)
            } else {
                storeImage.downloadURL { (url, err) in
                    if let error = err {
                        print(error.localizedDescription)
                    } else {
                        if let url = url?.absoluteString {
                            completion(url)
                        }
                    }
                }
            }
        }
    }
    
    func deleteImage(token:String) {
        let desertRef = storageRef.child("images").child(token)

        // Delete the file
        desertRef.delete { error in
          if let error = error {
            print(error.localizedDescription)
          }
        }
    }
    
    func getQuestionsAt(date: Date) {
        
    }
}
