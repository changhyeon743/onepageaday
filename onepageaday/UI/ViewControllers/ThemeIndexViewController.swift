//
//  ThemeIndexViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/26.
//

import UIKit

class ThemeIndexViewController: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var stickyView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var items: [Question] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        stickyView.layer.cornerRadius = 4.0
        stickyView.clipsToBounds = true
        
        titleLabel.text = title
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OFV_ContainerCollectionViewCell
        let view = OFV_MainView(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight),currentQuestion: items[indexPath.row])
        
        if let bg = items[indexPath.row].backGroundColor {
            view.backgroundColor = UIColor(bg)
        }
        cell.addSubview(view)

        view.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
        view.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}
