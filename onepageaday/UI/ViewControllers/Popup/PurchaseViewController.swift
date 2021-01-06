//
//  ProPurchaseViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2021/01/04.
//

import UIKit



class PurchaseViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var item: PurchaseItem?
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var detailText: UILabel!
    
    @IBOutlet weak var purchaseButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = self.item {
            titleText.text = item.title
            detailText.text = item.detail
            imageView.kf.setImage(with: URL(string: item.imageLink))
        }
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 32
        containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
        
        purchaseButton.layer.cornerRadius = 16
        purchaseButton.clipsToBounds = true
        purchaseButton.addAction(UIAction(handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }), for: .touchUpInside)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
