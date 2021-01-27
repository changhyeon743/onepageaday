//
//  NewsFeedDetailViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2021/01/28.
//

import UIKit

class NewsFeedDetailViewController: UIViewController {

    var ofv_mainView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
