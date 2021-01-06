//
//  ShopDetailViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/15.
//

import UIKit
import Kingfisher
import Firebase

class ShopDetailViewController: UIViewController {

    var shopItem: ShopItem?
    
    
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hashTagLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var privateModeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item = shopItem else {return}
        titleLabel.text = item.title
        
        let hashtagText = (item.hashtags.map{"#\($0)"}).joined(separator: " ")
        hashTagLabel.text =  hashtagText
        let privateText = item.privateMode ? "이 책의 답변은 기본적으로 비공개됩니다." : "이 책의 답변은 기본적으로 공개됩니다."
        privateModeLabel.text = privateText
        
        detailLabel.text = item.detail
        
        purchaseButton.setTitle("₩\(item.price)", for: .normal)
        purchaseButton.addAction(UIAction(handler: { _ in
            let book = Book(title: item.title,
                            detail: item.detail,
                            author: Auth.auth().currentUser?.uid ?? "",
                            currentIndex: 0,
                            backGroundImage: item.bookImage,
                            createDate: Date(),
                            modifiedDate: Date())
            
            API.firebase.addBook(book: book, question: item.questions, privateMode: item.privateMode) {
                let alert = UIAlertController(title: "다운로드 완료", message: "\(book.title)이(가) 서랍에 추가됨", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }), for: .touchUpInside)
        purchaseButton.layer.cornerRadius = 8
        purchaseButton.clipsToBounds = true
        
        if item.bookImage.isEmpty {
            bookImageView.removeFromSuperview()
        } else {
            bookImageView.kf.indicatorType = .activity
            bookImageView.kf.setImage(with: URL(string: item.bookImage))
        }
        
        item.additionalImageLinks.forEach { (url) in
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            imageView.kf.indicatorType = .activity
            imageView.contentMode = .scaleAspectFit
            imageView.kf.setImage(with: URL(string: url), completionHandler:  { (result) in
                switch result {
                case .success(let image):
                    let width = image.image.size.width/4
                    let height = image.image.size.height/4
                    print("\(width) / \(height)")
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    imageView.heightAnchor.constraint(equalToConstant: height).isActive=true
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
            })
            contentStackView.addArrangedSubview(imageView)
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
