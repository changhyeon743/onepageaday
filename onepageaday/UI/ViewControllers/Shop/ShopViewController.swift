//
//  ShopViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import UIKit
import FirebaseAuth
import SkeletonView
import FirebaseRemoteConfig
import SwiftyJSON

class ShopViewController: UIViewController, SkeletonTableViewDelegate, SkeletonTableViewDataSource {
    
    
    weak var parentDelegate: BookSelectingViewControllerDelegate?
    
    @IBOutlet var tableView: UITableView!
    var shopItems:[ShopItem]?
        /**/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        fetchShopItems()

        let nibName = UINib(nibName: "ShopCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func fetchShopItems() {
        let json = JSON(RemoteConfig.remoteConfig().configValue(forKey: "shop_items").jsonValue as Any)
        self.shopItems = json.arrayValue.map{ShopItem.mapping(json: $0)}
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ShopCell"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopItems?.count ?? 10
        
    }
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopItems?.count ?? 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //https://psycatgames.com/ko/magazine/conversation-starters/250-questions-to-ask-a-guy/#5
        if shopItems != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShopCell
            cell.hideSkeleton()
            cell.titleLabel.text = shopItems?[indexPath.row].title ?? ""
            
            //let hashtagText = (shopItems![indexPath.row].hashtags.map{"#\($0)"}).joined(separator: " ")
            
            cell.detailLabel.text =  shopItems?[indexPath.row].subTitle ?? ""
            
            
            cell.downloadButton.tag = indexPath.row
            cell.downloadButton.addTarget(self, action: #selector(downloadButtonPressed(_:)), for: .touchUpInside)
            cell.itemImageView?.kf.indicatorType = .activity
            cell.itemImageView?.kf.setImage(with: URL(string:shopItems![indexPath.row].bookImage))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShopCell
            cell.showAnimatedGradientSkeleton()
            cell.titleLabel.showAnimatedGradientSkeleton()
            cell.detailLabel.showAnimatedGradientSkeleton()
            cell.itemImageView.showAnimatedGradientSkeleton()
            cell.downloadButton.showAnimatedGradientSkeleton()
            return cell
        }
    }
    
    @objc func downloadButtonPressed(_ sender:UIButton) {
        let row = sender.tag
        if (shopItems == nil) { return }
        let book = Book(title: shopItems![row].title,
                        subTitle: shopItems![row].subTitle,
                        detail: shopItems![row].detail,
                        author: Auth.auth().currentUser?.uid ?? "",
                        currentIndex: 0,
                        backGroundImage: shopItems![row].bookImage,
                        createDate: Date(),
                        modifiedDate: Date())
        
        API.firebase.addBook(book: book, question: shopItems![row].questions, privateMode: shopItems![row].privateMode) {
            let alert = UIAlertController(title: "다운로드 완료", message: "\(book.title)이(가) 서랍에 추가됨", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            self.parentDelegate?.bookDownloaded()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ShopDetailViewController") as? ShopDetailViewController {
            vc.title = shopItems?[indexPath.row].title
            vc.shopItem = shopItems?[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}
