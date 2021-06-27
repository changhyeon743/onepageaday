//
//  ThemeIndexViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/26.
//

import UIKit
import Firebase
import SkeletonView
import SnapKit
import Gemini
import AppTrackingTransparency
import GoogleMobileAds

protocol NewsFeedViewControllerDelegate : class {
    func save(uiimage: UIImage)
    func report(questionId: String)
}

//오늘의 매일력 / 기타 등등
//TODO: Skeleton
class NewsFeedViewController: UIViewController  {
    
    @IBOutlet weak var collectionView: GeminiCollectionView!
    lazy private var activityIndicator: UIActivityIndicatorView = { return makeActivityIndicator(center: self.view.center) }()
    
    private var lastDocument: DocumentSnapshot?
    private var items: [AnyObject]?
    private var refreshControl = UIRefreshControl()
    private var adLoader:GADAdLoader?
    private var isWaitingForFetch: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    let limit = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        fetchData()
        
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            self.loadAd()
        })
    }
    
    func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.allowsSelection = false
        collectionView.showsVerticalScrollIndicator = false
        
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        
        collectionView.gemini.cubeAnimation().cubeDegree(90).shadowEffect(.fadeIn).maxShadowAlpha(0.35)

        collectionView.reloadData()
    }
    
    func loadAd() {
        adLoader = GADAdLoader(
          adUnitID: "ca-app-pub-3940256099942544/3986624511", rootViewController: self,
          adTypes: [.native], options: nil)
        adLoader?.delegate = self
        adLoader?.load(GADRequest())
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.items = nil
        
        fetchData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.animateVisibleCells()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.isSelected = false
    }
    
    func fetchData() {
        self.activityIndicator.startAnimating()
        API.firebase.fetchNewestQuestions(after: nil, limit: limit) { (questions,lastDocument)  in
            if self.items?.count ?? 0 > 0 {
                self.items?.append(contentsOf: questions as [AnyObject])
            } else {
                self.items = questions as [AnyObject]
            }
            self.collectionView.reloadData()
            self.lastDocument = lastDocument
            self.activityIndicator.stopAnimating()
            self.noResult()
            self.refreshControl.endRefreshing()
            self.loadAd()
        }
//        } else if (self.theme == Theme.titleSearch){
//            API.firebase.fetchQuestion(withName: self.title ?? "", after: nil) { (questions,lastDocument)  in
//                self.items = questions
//                self.collectionView.reloadData()
//                self.lastDocument = lastDocument
//                self.noResult()
//                self.activityIndicator.stopAnimating()
//            }
//        }
        
    }
    func noResult() {
        if (self.items?.count == 0) {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.width, height: self.collectionView.bounds.height))
            let label = UILabel(frame: CGRect(x: 12, y: 12, width: 100, height: 50))
            label.text = "검색결과 없음"
            label.textColor = .label
            view.addSubview(label)
            self.collectionView.backgroundView = view
        } else {
            self.collectionView.backgroundView = nil
        }
    }
    
    func addData() {
        if let last = lastDocument {
            activityIndicator.startAnimating()
            API.firebase.fetchNewestQuestions(after: last, limit: limit) { (questions,lastDocument)  in
                self.activityIndicator.stopAnimating()
                self.items?.append(contentsOf: questions as [AnyObject])
                self.collectionView.reloadData()
                self.isWaitingForFetch = false
                self.lastDocument = lastDocument
                self.loadAd()
            }
            
        } else {
            print("이미 마지막")
        }
    }
    
}

extension NewsFeedViewController: GADAdLoaderDelegate,GADNativeAdLoaderDelegate, GADVideoControllerDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.items?.append(nativeAd)
//        print("ad Loaded",nativeAd.debugDescription,self.items?.debugDescription)
        self.collectionView.reloadData()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
}


extension NewsFeedViewController: NewsFeedViewControllerDelegate {
    func save(uiimage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiimage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func report(questionId: String) {
        let actionSheet = UIAlertController(title: "신고 사유 선택", message: nil, preferredStyle: .actionSheet)
        ["상업적 광고 및 판매","정당/정치인 비하 및 선거운동","욕설/비하","놀람/도배","음란물"].forEach { (title) in
            actionSheet.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                API.firebase.addReport(questionId: questionId, content: title) {
                    let alert = UIAlertController(title: "신고가 완료되었습니다.", message: "검토 후에 적절한 처리가 이루어질 예정입니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                // we got back an error!
                print(error.localizedDescription)
            } else {
                print("saved")
                let alert = UIAlertController(title: "갤러리에 저장", message: "갤러리에 저장되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
}

extension NewsFeedViewController: SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let numberOfCellsInRow = 1
//        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//        let totalSpace = flowLayout.sectionInset.left +
//            flowLayout.sectionInset.right +
//            (flowLayout.minimumInteritemSpacing * CGFloat(numberOfCellsInRow - 1))
//
//        let size = CGFloat((collectionView.bounds.width - totalSpace) / CGFloat(numberOfCellsInRow))
//        return CGSize(width: size, height: size * Constant.OFV.cellHeight / Constant.OFV.cellWidth)
        return .init(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cell"
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThemeCollectionViewCell
        self.collectionView.animateCell(cell)
        
        if let items = self.items {
            print("Hellomynameis",(self.items?[indexPath.row] as? Question) != nil,(self.items?[indexPath.row] as? GADNativeAd) != nil,  type(of: self.items?[indexPath.row]))
            if let item = self.items?[indexPath.row] as? Question {
                cell.hideSkeleton()

    //            let inset:CGFloat = 128
    //            let height = (self.collectionView.frame.width - inset*2) * Constant.OFV.cellHeight / Constant.OFV.cellWidth
                
                let inset:CGFloat = 0
                let height = self.collectionView.frame.height - inset/2
                let width = (height) * Constant.OFV.cellWidth / Constant.OFV.cellHeight
                
                let view = OFV_MainView(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight),currentQuestion: item,_magnification:
                                            ( Constant.OFV.cellWidth ) / ( width )
                                        )
                
                if let bg = item.backGroundColor {
                    view.backgroundColor = UIColor(bg)
                }
                
                cell.id = item.id
                cell.parentDelegate = self
                cell.ofv_mainView = view
    //            cell.backgroundColor = Constant.Design.mainBackGroundColor
                let interaction = UIContextMenuInteraction(delegate: cell)
                cell.addInteraction(interaction)
                cell.isUserInteractionEnabled = true
                
                cell.addSubview(cell.ofv_mainView ?? UIView())
                cell.ofv_mainView?.snp.makeConstraints{
                    $0.top.bottom.equalTo(cell).inset(inset)
                    $0.width.equalTo(width)
                    $0.centerX.equalToSuperview()
                }
                cell.configure(ofv_mainView: view)

                return cell
            } else if let nativeAd = self.items?[indexPath.row] as? GADNativeAd {
                cell.configure(nativeAd: nativeAd)
                
                return cell
            }
            
        } else {
            cell.showAnimatedGradientSkeleton()
            return cell
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? GeminiCell {
            self.collectionView.animateCell(cell)
        }
        
        guard let cnt = self.items?.count else {return}
        
        if indexPath.row == cnt - 1 && !isWaitingForFetch {
            isWaitingForFetch = true
            addData()
        }
    }
    
}
