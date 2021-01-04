//
//  ThemeIndexViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/26.
//

import UIKit
import Firebase
import SkeletonView

//오늘의 매일력 / 기타 등등
//TODO: Skeleton
class ThemeIndexViewController: UIViewController , SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching {
    
    lazy var activityIndicator: UIActivityIndicatorView = { return makeActivityIndicator(center: self.view.center) }()
    
    
    
    enum Theme:Int {
        case titleSearch, today
    }
    
    var theme: Theme?
    var lastDocument: DocumentSnapshot?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var stickyView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var items: [Question]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        stickyView.layer.cornerRadius = 4.0
        stickyView.clipsToBounds = true
        
        titleLabel.text = title
        self.view.addSubview(activityIndicator)
        fetchData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cell"
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let items = self.items {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThemeCollectionViewCell
            let view = OFV_MainView(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight),currentQuestion: items[indexPath.row])
            
            if let bg = items[indexPath.row].backGroundColor {
                view.backgroundColor = UIColor(bg)
            }
            cell.stopSkeletonAnimation()
            cell.addSubview(view)
            let interaction = UIContextMenuInteraction(delegate: cell)
            cell.addInteraction(interaction)
            cell.isUserInteractionEnabled = true
            view.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            view.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            view.translatesAutoresizingMaskIntoConstraints = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThemeCollectionViewCell
            cell.showAnimatedGradientSkeleton()
            return cell
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let items = self.items else {return}
        for indexPath in indexPaths {
            print(indexPath.row)
            if items.count == items.count - indexPath.row { //Don't know why...
              print("ADD DATA")
                addData()
            }
          }
    }
    
    func fetchData() {
        if (self.theme == Theme.today) {
            API.firebase.fetchQuestionToday(after: nil) { (questions,lastDocument)  in
                self.items = questions
                self.collectionView.reloadData()
                self.lastDocument = lastDocument
            }
        } else if (self.theme == Theme.titleSearch){
            API.firebase.fetchQuestion(withName: self.title ?? "", after: nil) { (questions,lastDocument)  in
                self.items = questions
                self.collectionView.reloadData()
                self.lastDocument = lastDocument
            }
        }
        
    }
    
    func addData() {
        if let last = lastDocument {
            activityIndicator.startAnimating()
            if (self.theme == Theme.today) {
                API.firebase.fetchQuestionToday(after: last) { (questions,lastDocument)  in
                    self.activityIndicator.stopAnimating()
                    self.items?.append(contentsOf: questions)
                    self.collectionView.reloadData()
                    self.lastDocument = lastDocument
                }
            } else if (self.theme == Theme.titleSearch) {
                API.firebase.fetchQuestion(withName: self.title ?? "", after: nil) { (questions,lastDocument)  in
                    self.activityIndicator.stopAnimating()
                    self.items?.append(contentsOf: questions)
                    self.collectionView.reloadData()
                    self.lastDocument = lastDocument
                }
            }
            
        } else {
            print("이미 마지막")
        }
    }
}
