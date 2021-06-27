//
//  ProPurchaseViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2021/01/04.
//

import UIKit



class PurchaseViewController: UIViewController {
    
    class func present(on viewController: UIViewController) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PurchaseViewController") as? PurchaseViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            viewController.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func purchaseButtonPressed(_ sender: Any) {
        print("purchase")
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
