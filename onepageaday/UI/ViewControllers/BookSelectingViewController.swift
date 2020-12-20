//
//  BookSelectingViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/11.
//

import UIKit
import Firebase
import SkeletonView

private let reuseIdentifier = "cell"

protocol BookSelectingViewControllerDelegate: class {
    
    //For shop
    func bookDownloaded()
    
    
}


class BookSelectingViewController: UIViewController, SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource,BookSelectingViewControllerDelegate,UIAdaptivePresentationControllerDelegate {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
            // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.backgroundColor = .init(white: 0, alpha: 0.5)
        activityIndicator.layer.cornerRadius = 14
        activityIndicator.clipsToBounds = true
        activityIndicator.color = .white
        
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        // Start animation.
        activityIndicator.stopAnimating()
        return activityIndicator }()
    
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
        self.view.addSubview(activityIndicator)
        self.presentationController?.delegate = self
    
        self.collectionView.showAnimatedGradientSkeleton()

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
            
            API.books?.sort { $0.createDate > $1.createDate }
            self.collectionView.hideSkeleton()
            self.collectionView.reloadData()
        })
    }

    @IBAction func trashButtonPressed(_ sender: Any) {
        //or?
        if currentPage < API.books?.count ?? 0 {
            let alert = UIAlertController(title: "삭제", message: "\(API.books?[currentPage].title ?? "") 을(를) 삭제하시겠습니까?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                API.firebase.deleteBook(with: API.books?[self.currentPage].id ?? "")
                API.books?.remove(at: self.currentPage)
                
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return API.books?.count ?? 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return API.books?.count ?? 10
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return reuseIdentifier
    }



    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (API.books != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
            cell.hideSkeleton()
            
            cell.titleLabel.text = API.books?[indexPath.row].title
            cell.dateLabel.text = API.books?[indexPath.row].createDate.toString()
            cell.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
            cell.showAnimatedGradientSkeleton()
            return cell
        }
        
        // Configure the cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = API.books?[indexPath.row].id else {return}
        activityIndicator.startAnimating()
        //부드럽게 만드는거 필요함
        API.firebase.fetchQuestion(with: id) { (questions) in
            self.activityIndicator.stopAnimating()
            API.currentQuestions = questions
            API.currentQuestions.sort{$0.index < $1.index}
            if let vc = self.storyboard!.instantiateViewController(identifier: "MainPageViewController") as? MainPageViewController {
                //vc.modalPresentationStyle = .overCurrentContext
                vc.modalPresentationStyle = .fullScreen
                vc.book = API.books?[indexPath.row]
                vc.currentIndex = API.books?[indexPath.row].currentIndex ?? 0
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
