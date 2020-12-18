//
//  BookSelectingViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/11.
//

import UIKit
import Firebase

private let reuseIdentifier = "cell"

protocol BookSelectingViewControllerDelegate: class {
    func bookDownloaded()
}


class BookSelectingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,BookSelectingViewControllerDelegate,UIAdaptivePresentationControllerDelegate {
    
    
    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var settingButton: UIButton!
    
    var currentPage:Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        fetchBooks()
    }
    //상점 종료시 목록 업데이트
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        viewWillAppear(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentationController?.delegate = self
        

        settingButton.showsMenuAsPrimaryAction = true
        settingButton.menu = UIMenu(title: "설정",
                                     image: UIImage(systemName: "gear"),
                                     identifier: nil,
                                     options: .displayInline,
                                     children: [UIAction(title: "로그아웃", image: UIImage(systemName: "person.crop.circle.badge.xmark"), handler: { _ in
                                        //로그아웃
                                        do {
                                            try Auth.auth().signOut()
                                            self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController")
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        
                                     })])
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let nibName = UINib(nibName: "BookCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "cell")
        
        let layout = BookFlowLayout()
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.decelerationRate = UIScrollView.DecelerationRate.fast
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func fetchBooks() {
        API.firebase.fetchBooks(with: Auth.auth().currentUser?.uid ?? "", completion: { (books) in
            API.books = books
            //self.books.sort { $0. < $1.deadline }

            self.collectionView.reloadData()
        })
    }

    @IBAction func trashButtonPressed(_ sender: Any) {
        if currentPage < API.books.count {
            let alert = UIAlertController(title: "삭제", message: "\(API.books[currentPage].title) 을(를) 삭제하시겠습니까?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                API.firebase.deleteBook(with: API.books[self.currentPage].id ?? "")
                API.books.remove(at: self.currentPage)
                
                self.collectionView.reloadData()
                
                self.viewDidLayoutSubviews()
            }))
            alert.addAction(UIAlertAction(title: "취소하기", style: .cancel, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func enterShop(_ sender: Any) {
//        let db = Firestore.firestore()
//        db.collection("Information").document("shop").getDocument() { (snapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                let vc = ShopViewController()
//                let jsons = JSON(JSON(snapshot?.data()))["json"].arrayValue
//            }
//        }
        if let vc = self.storyboard?.instantiateViewController(identifier: "ShopNavigationViewController") {
            //vc.parentDelegate = self
            vc.presentationController?.delegate = self
            present(vc, animated: true, completion: nil)
        }
       // self.collectionView.reloadData()t
//        

    }
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return API.books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
        cell.titleLabel.text = API.books[indexPath.row].title
        
        cell.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
        // Configure the cell
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = API.books[indexPath.row].id else {return}
        
        //부드럽게 만드는거 필요함
        API.firebase.fetchQuestion(with: id) { (questions) in
            API.currentQuestions = questions
            API.currentQuestions.sort{$0.index < $1.index}
            if let vc = self.storyboard!.instantiateViewController(identifier: "MainPageViewController") as? MainPageViewController {
                //vc.modalPresentationStyle = .overCurrentContext
                vc.modalPresentationStyle = .fullScreen
                vc.book = API.books[indexPath.row]
                self.present(vc, animated:true, completion: nil)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        // Do whatever with currentPage.
        self.currentPage = currentPage
    }
    
    func bookDownloaded() {
        fetchBooks()
    }
}
