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

enum AdditionalItem: Int {
    case openShop
//    case todayBooks
//    case buyPro
    case buyRealBook
    
    static let count = 4
}

func makeActivityIndicator(center: CGPoint) -> UIActivityIndicatorView {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    activityIndicator.center = center
    activityIndicator.backgroundColor = .init(white: 0, alpha: 0.5)
    activityIndicator.layer.cornerRadius = 14
    activityIndicator.clipsToBounds = true
    activityIndicator.color = .white
    
    // Also show the indicator even when the animation is stopped.
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = .large
    // Start animation.
    activityIndicator.stopAnimating()
    return activityIndicator
}

class BookSelectingViewController: UIViewController, SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource,BookSelectingViewControllerDelegate,UIAdaptivePresentationControllerDelegate {
    
    lazy var activityIndicator: UIActivityIndicatorView = { return makeActivityIndicator(center: self.view.center) }()
    
    @IBOutlet weak var trashButton: UIButton!
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
    
        //Firestore.firestore().disableNetwork(completion: nil)
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


                                     }),
                                     
                                     ])
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
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if (API.books == nil) {
            return 1
        }
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return API.books?.count ?? 10
        } else {
            return AdditionalItem.count
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return API.books?.count ?? 10
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return reuseIdentifier
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (API.books != nil) {
            if (indexPath.section == 0) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
                cell.titleLabel.hideSkeleton()
                cell.dateLabel.hideSkeleton()
                cell.imageView.hideSkeleton()
                
                cell.titleLabel.text = API.books?[indexPath.row].title
                cell.dateLabel.text = API.books?[indexPath.row].createDate.toString()
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
                cell.titleLabel.hideSkeleton()
                cell.dateLabel.hideSkeleton()
                cell.imageView.hideSkeleton()
                cell.imageView.kf.indicatorType = .activity

                switch indexPath.row{
                case AdditionalItem.openShop.rawValue:
                    cell.titleLabel.text = "상점"
                    cell.dateLabel.text = "새로운 매일력을 다운로드 하세요."
                    cell.imageView.kf.setImage(with: URL(string: "https://product-image.juniqe-production.juniqe.com/media/catalog/product/seo-cache/x800/648/28/648-28-101P/Today-Is-The-Day-Kind-of-Style-Poster.jpg"))
                    break
//                case AdditionalItem.todayBooks.rawValue:
//                    cell.titleLabel.text = "오늘의 매일력"
//                    cell.dateLabel.text = "오늘의 매일력을 볼 수 있습니다."
//                    cell.imageView.kf.setImage(with: URL(string: "https://product-image.juniqe-production.juniqe.com/media/catalog/product/seo-cache/x800/648/28/648-28-101P/Today-Is-The-Day-Kind-of-Style-Poster.jpg"))
//                    break
//                case AdditionalItem.buyPro.rawValue:
//                    cell.titleLabel.text = "프로 버전 구매하기"
//                    cell.dateLabel.text = "₩1000"
//                    cell.imageView.kf.setImage(with: URL(string: "https://store.storeimages.cdn-apple.com/8756/as-images.apple.com/is/MWP22_AV1?wid=1144&hei=1144&fmt=jpeg&qlt=80&op_usm=0.5,0.5&.v=1591634652000"))
//                    break
                case AdditionalItem.buyRealBook.rawValue:
                    cell.titleLabel.text = "매일력 책 구매하기"
                    cell.dateLabel.text = "리마크프레스 사이트로 연결됩니다"
                    cell.imageView.kf.setImage(with: URL(string: "https://contents.sixshop.com/thumbnails/uploadedFiles/13311/product/image_1581581880733_1000.jpg"))
                    break
                default: break
                    
                }
                
                return cell
            }
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
            cell.titleLabel.showAnimatedGradientSkeleton()
            cell.dateLabel.showAnimatedGradientSkeleton()
            cell.imageView.showAnimatedGradientSkeleton()
            return cell
        }
        
        // Configure the cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
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
        } else {
            switch indexPath.row {
            case AdditionalItem.openShop.rawValue:
                enterShop(nil)
                break
//            case AdditionalItem.todayBooks.rawValue:
//                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ThemeIndexViewController") as? NewsFeedViewController {
//                    //vc.theme = .today
//                    
//                    self.present(vc, animated: true, completion: nil)
//                }
//                
//                break
//            case AdditionalItem.buyPro.rawValue:
//                //Buy pro
//                print("Buy pro")
//                if let vc = self.storyboard?.instantiateViewController(identifier: "PurchaseViewController") as? PurchaseViewController {
//                    vc.modalPresentationStyle = .overCurrentContext
//                    vc.modalTransitionStyle = .crossDissolve
//                    present(vc, animated: true, completion: nil)
//                }
//                break
            case AdditionalItem.buyRealBook.rawValue:
                //open safari
                if let url = URL(string: "https://www.sixshop.com/remarkpress/product/9") {
                    UIApplication.shared.open(url)
                }
                break
            default:
                break
            }
        }
        
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        trashButton.isHidden = false
        
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        // Do whatever with currentPage.
        self.currentPage = currentPage
        
        guard let bookCount = API.books?.count else {return}
        if currentPage >= bookCount {
            trashButton.isHidden = true
        } else {
            trashButton.isHidden = false
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        trashButton.isHidden = true
    }
    
    
    
    func bookDownloaded() {
        fetchBooks()
    }
    
    
    
}
