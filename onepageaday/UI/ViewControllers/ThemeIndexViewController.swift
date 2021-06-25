//
//  ThemeIndexViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2021/06/23.
//

import Foundation
import UIKit
import Firebase
import SkeletonView


class ThemeIndexViewController: UIViewController , SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    lazy var activityIndicator: UIActivityIndicatorView = { return makeActivityIndicator(center: self.view.center) }()
    
    var lastDocument: DocumentSnapshot?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var items: [Question]?
    
    var refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
//        collectionView.isPagingEnabled = true
        self.titleLabel.text = self.title
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)

        fetchData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.items = nil
        
        fetchData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsInRow = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left +
            flowLayout.sectionInset.right +
            (flowLayout.minimumInteritemSpacing * CGFloat(numberOfCellsInRow - 1))
        
        let size = CGFloat((collectionView.bounds.width - totalSpace) / CGFloat(numberOfCellsInRow))
        return CGSize(width: size, height: size * Constant.OFV.cellHeight / Constant.OFV.cellWidth)
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
            let view = OFV_MainView(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight),currentQuestion: items[indexPath.row],_magnification: 2)
            
            if let bg = items[indexPath.row].backGroundColor {
                view.backgroundColor = UIColor(bg)
            }
            
            cell.id = items[indexPath.row].id
            cell.stopSkeletonAnimation()
            cell.ofv_mainView = view
            
            
            let interaction = UIContextMenuInteraction(delegate: cell)
            cell.addInteraction(interaction)
            cell.isUserInteractionEnabled = true
            
            cell.addSubview(cell.ofv_mainView ?? UIView())
            cell.ofv_mainView?.snp.makeConstraints{
                $0.edges.equalTo(cell)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThemeCollectionViewCell
            cell.showAnimatedGradientSkeleton()
            return cell
        }
        
    }
    
    var isWaitingForFetch: Bool = false
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cnt = self.items?.count else {return}
        
        if indexPath.row == cnt - 1 && !isWaitingForFetch {
            isWaitingForFetch = true
            addData()
        }
    }
    
    
    func fetchData() {
        self.activityIndicator.startAnimating()
        API.firebase.fetchQuestion(withName: self.title ?? "", after: nil) { (questions,lastDocument)  in
            self.items = questions
            self.collectionView.reloadData()
            self.lastDocument = lastDocument
            self.noResult()
            self.activityIndicator.stopAnimating()
        }
        
        
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
            API.firebase.fetchQuestion(withName: self.title ?? "", after: lastDocument) { (questions,lastDocument)  in
                self.activityIndicator.stopAnimating()
                self.items?.append(contentsOf: questions)
                self.collectionView.reloadData()
                self.lastDocument = lastDocument
            }
            
        } else {
            print("이미 마지막")
        }
    }
}
