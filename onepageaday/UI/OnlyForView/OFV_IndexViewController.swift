//
//  OFV_IndexViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/22.
//

import UIKit

// 모아보기!
class OFV_IndexViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //위에 회색
    @IBOutlet weak var stickyView: UIView!
    
    var filteredData = API.currentQuestions

    var searchMode = 0
    
    var pageViewControllerDelegate: MainPageViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchBar.delegate = self
        
        stickyView.layer.cornerRadius = 4.0
        stickyView.clipsToBounds = true
    }
    deinit {
        print("OFV_IndexViewController deinit")
    }


}

extension OFV_IndexViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateItemsWith(searchText: searchText)
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        print(selectedScope)
        self.searchMode = selectedScope
        //목록 업데이트
        updateItemsWith(searchText: searchBar.text ?? "")
    }
    
    func updateItemsWith(searchText: String) {
        if searchText.isEmpty { //전체 검색
            if searchMode == 0 { //모든 질문
                filteredData = API.currentQuestions
            } else if searchMode == 1{ //답변이 있는 질문
                filteredData = API.currentQuestions
                    .filter{ $0.textViewDatas.count > 0 || $0.imageViewDatas.count > 0 || $0.drawings.isEmpty == false}
            }
        } else {
            if searchMode == 0 { //모든 질문
                filteredData = API.currentQuestions.filter { $0.text.contains(searchText) }
            } else if searchMode == 1{ //답변이 있는 질문
                filteredData = API.currentQuestions
                    .filter{ $0.textViewDatas.count > 0 || $0.imageViewDatas.count > 0 || $0.drawings.isEmpty == false}
                    .filter { $0.text.contains(searchText) }
            }
        }
        self.view.endEditing(true)
        self.collectionView.reloadData()
    }
}

///배율(역수)

extension OFV_IndexViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OFV_ContainerCollectionViewCell
        let view = OFV_MainView(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight),currentQuestion: filteredData[indexPath.row])
        
        if let bg = filteredData[indexPath.row].backGroundColor {
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        pageViewControllerDelegate?.setViewControllerIndex(index: filteredData[indexPath.row].index)
        dismiss(animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}
