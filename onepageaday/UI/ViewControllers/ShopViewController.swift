//
//  ShopViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import UIKit

class ShopViewController: UITableViewController {
    public var books:[BookTemplate] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        let nibName = UINib(nibName: "ShopCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShopCell
        cell.titleLabel.text = String(indexPath.row)
        cell.detailLabel.text = "설명"
        cell.itemImageView?.kf.setImage(with: URL(string: "https://mblogthumb-phinf.pstatic.net/MjAyMDA0MjJfMjQz/MDAxNTg3NTE3NDc2NTYw.VK48O2JjR7bghJqHAc82_t1e84ZJkjbiDwchX3nccAgg.M-xUCBA-5fE9_v6l5obnj5y81WBCIWxnV7ECmUOFJRkg.JPEG.paichaiuniv/%EA%B3%A8%EB%93%9C%EB%84%A5%EC%8A%A4_%EB%B0%B0%EC%9E%AC%EB%8C%80%ED%95%99%EA%B5%90_%EB%B8%94%EB%A1%9C%EA%B7%B8_%EC%84%AC%EB%84%A4%EC%9D%BC_%ED%99%94%EC%9D%B4%ED%8A%B8.jpg?type=w800"))

        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: self)
    }

}
