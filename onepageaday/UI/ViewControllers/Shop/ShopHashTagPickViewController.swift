//
//  ShopHashTagPickViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2021/01/01.
//

import UIKit

///Deprecated
class ShopHashTagPickViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    

    let shopItems = ShopItems().shopItems
    
    var hashTags:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //해시태그 모으기 Set(중복제거 위해)
        hashTags = (Array(Set(shopItems.map{$0.hashtags}.joined())))
        tableView.reloadData()
        
        //[["남자", "50가지 이상", "무료", "최근발매"], ["여자", "50가지 이상", "무료", "최근발매"]]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = "# \(hashTags[indexPath.row])"
        
        //해시태그 걸려있는 아이템 개수 계산
        cell.detailTextLabel?.text = String(shopItems.filter({ (item) -> Bool in
            return item.hashtags.contains(hashTags[indexPath.row])
        }).count)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "ShopViewController") as? ShopViewController {
            vc.shopItems = shopItems.filter({ (item) -> Bool in
                return item.hashtags.contains(hashTags[indexPath.row])
            })
            vc.title = "# \(hashTags[indexPath.row])"
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
    }

}
