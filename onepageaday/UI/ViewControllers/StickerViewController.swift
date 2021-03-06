//
//  StickerViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/21.
//

import UIKit
import Kingfisher
import SwiftyJSON

class StickerViewController: UIViewController,UISearchBarDelegate {
    
    var mode: GiphyMode = .sticker

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //위에 회색
    @IBOutlet weak var stickyView: UIView!
    
    var parentDelegate: MainViewControllerDelegate?
    
    var items: [String]?
    
    var items_forParent: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        stickyView.layer.cornerRadius = 4.0
        stickyView.clipsToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchBar(searchBar, textDidChange: "")
        
        self.searchBar.becomeFirstResponder()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            API.giphyApi.getTrendContents(mode: mode) { (json) in
                self.items = json["data"].arrayValue.map{$0["images"]["preview_gif"]["url"].stringValue}
                self.items_forParent = json["data"].arrayValue.map{$0["images"]["fixed_width"]["url"].stringValue}

                self.collectionView.performBatchUpdates({
                    let indexSet = IndexSet(integersIn: 0...0)
                    self.collectionView.reloadSections(indexSet)
                }, completion: nil)
            }
        } else {
            API.giphyApi.search(with: searchBar.text!, mode: mode) { (json) in
                print(json["data"].arrayValue)
                self.items = json["data"].arrayValue.map{$0["images"]["preview_gif"]["url"].stringValue}
                self.items_forParent = json["data"].arrayValue.map{$0["images"]["fixed_width"]["url"].stringValue}
                
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

                self.collectionView.performBatchUpdates({
                    let indexSet = IndexSet(integersIn: 0...0)
                    self.collectionView.reloadSections(indexSet)
                }, completion: nil)
            }
        }
        print(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    

}

extension StickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width/3, height: self.view.bounds.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let guard_items = items else {return 10}
        return guard_items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (items == nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StickerCell
            cell.imageView.showAnimatedGradientSkeleton()
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StickerCell
            cell.imageView.hideSkeleton()
            cell.imageView.kf.indicatorType = .activity
            cell.imageView.kf.setImage(with: URL(string: items![indexPath.row]), options: [ .diskCacheExpiration(.expired),.memoryCacheExpiration(.expired)])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = items_forParent?[indexPath.row] {
            self.parentDelegate?.insertSticker(url: url, token: UUID().uuidString)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
