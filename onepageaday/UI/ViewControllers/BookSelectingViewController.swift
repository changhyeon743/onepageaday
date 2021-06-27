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


class BookSelectingViewController: UIViewController,UIAdaptivePresentationControllerDelegate {
    
    lazy var activityIndicator: UIActivityIndicatorView = { return makeActivityIndicator(center: self.view.center) }()
    
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var settingButton: UIButton!
    var currentPage:Int = 0
    
    var isNewUser = false
    
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
        
        //Firestore.firestore().disableNetwork(completion: nil)
        self.collectionView.showAnimatedGradientSkeleton()
        let nibName = UINib(nibName: "BookCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "cell")
        
        let layout = BookFlowLayout()
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.decelerationRate = UIScrollView.DecelerationRate.fast
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.view.backgroundColor = Constant.Design.mainBackGroundColor
        self.collectionView.backgroundColor = Constant.Design.mainBackGroundColor
        
        
        settingButton.showsMenuAsPrimaryAction = true
        settingButton.menu = UIMenu(title: "계정",
                                     image: UIImage(systemName: "person.circle"),
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


                                     }),
                                     
                                     ])
        
        [settingButton,shopButton].forEach{$0?.tintColor = Constant.Design.mainTintColor}
        self.detailLabel.textColor = Constant.Design.mainTintColor
        self.detailLabel.font = .cafe(size: 20)
    }
    
    func fetchBooks() {
        API.firebase.fetchBooks(with: Auth.auth().currentUser?.uid ?? "", completion: { (books) in
            API.books = books
            
            API.books?.sort { $0.createDate > $1.createDate }
            self.collectionView.hideSkeleton()
            
            self.collectionView.reloadData()
            self.scrollViewDidEndDecelerating(self.collectionView)
        })
    }

    @IBAction func trashButtonPressed(_ sender: UIButton) {
        //or?
        guard let bookCount = API.books?.count else {return}
        
        if currentPage < bookCount && bookCount > 1{
            let alert = UIAlertController(title: "\(API.books?[currentPage].title ?? "") 을(를) 삭제하시겠습니까?", message:  nil, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                
                API.firebase.deleteBook(with: API.books?[self.currentPage].id ?? "")
                API.books?.remove(at: self.currentPage)
                let indexPath = IndexPath(item: self.currentPage, section: 0)
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at:[indexPath])
                }, completion:{ [weak self] _ in
                    self?.scrollViewDidEndDecelerating(self!.collectionView)
                })
                
                
                self.viewDidLayoutSubviews()
            }))
            alert.addAction(UIAlertAction(title: "취소하기", style: .cancel, handler: nil))
            alert.popoverPresentationController?.sourceView = sender as UIView

            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "삭제 실패", message: "1개 이상의 책을 소지하고 있어야합니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func enterShop(_ sender: Any?) {
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        trashButton.isHidden = false
        detailLabel.isHidden = false
        
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        // Do whatever with currentPage.
        self.currentPage = currentPage
        
        guard let books = API.books else {
            trashButton.isHidden = true
            detailLabel.isHidden = true
            return
        }
        
        if currentPage >= books.count || books.count < 1 {
            trashButton.isHidden = true
            detailLabel.isHidden = true
        } else {
            trashButton.isHidden = false
            detailLabel.isHidden = false
            
            let day = Calendar.current.dateComponents([.day],
                                                              from: books[currentPage].createDate ?? Date(), to: books[currentPage].modifiedDate
                                                                  ?? Date()).day ?? 0
            let attributedString = NSMutableAttributedString.init(string: "함께한지 \(day+1)일 째")
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSRange.init(location: attributedString.string.count - "\(day+1)일 째".count, length: "\(day)일 째".count))
            
            self.detailLabel.attributedText = attributedString
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        trashButton.isHidden = true
        detailLabel.isHidden = true
    }
    
    
}

extension BookSelectingViewController: BookSelectingViewControllerDelegate {
    //Delegate
    func bookDownloaded() {
        fetchBooks()
    }
}

extension BookSelectingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return API.books?.count ?? 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (API.books != nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
            cell.titleLabel.hideSkeleton()
            cell.detailLabel.hideSkeleton()
            cell.imageView.hideSkeleton()
            
            cell.titleLabel.text = API.books?[indexPath.row].title
            cell.detailLabel.text = API.books?[indexPath.row].subTitle
            //cell.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
            if let url = API.books?[indexPath.row].backGroundImage {
                cell.imageView.kf.indicatorType = .activity
                cell.imageView.kf.setImage(with: URL(string: url))
            } else {
                cell.imageView.image = nil
                cell.imageView.backgroundColor = UIColor(Constant.Design.backGroundColors.randomElement() ?? defaultColor)
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
            cell.titleLabel.showAnimatedGradientSkeleton()
            cell.detailLabel.showAnimatedGradientSkeleton()
            cell.imageView.showAnimatedGradientSkeleton()
            return cell
        }
        
        // Configure the cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let id = API.books?[indexPath.row].id else {return}
            activityIndicator.startAnimating()
            //부드럽게 만드는거 필요함
            API.firebase.fetchQuestions(with: id) { (questions) in
                self.activityIndicator.stopAnimating()
                
                if (questions.count > 0) {
                    API.currentQuestions = questions
                    if let vc = self.storyboard!.instantiateViewController(identifier: "MainPageViewController") as? MainPageViewController {
                        //vc.modalPresentationStyle = .overCurrentContext
                        vc.modalPresentationStyle = .fullScreen
                        vc.book = API.books?[indexPath.row]
                        vc.currentIndex = API.books?[indexPath.row].currentIndex ?? 0
                        self.present(vc, animated:true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "오류", message: "정상적으로 불러올 수 없음", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        
        
        }

    
}
