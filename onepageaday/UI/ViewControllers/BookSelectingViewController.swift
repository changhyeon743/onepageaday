//
//  BookSelectingViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/11.
//

import UIKit
import Firebase
import SwiftyJSON

private let reuseIdentifier = "cell"



class BookSelectingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView:UICollectionView!
    
    var books:[Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let nibName = UINib(nibName: "BookCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "cell")
        
        let layout = BookFlowLayout()
        self.collectionView!.collectionViewLayout = layout
        self.collectionView!.decelerationRate = UIScrollView.DecelerationRate.fast
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }

    @IBAction func enterShop(_ sender: Any) {
//        let db = Firestore.firestore()
//        db.collection("Information").document("shop").getDocument() { (snapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                let vc = ShopViewController()
//                let jsons = JSON(JSON(snapshot?.data()))["json"].arrayValue
//            }
//        }
        performSegue(withIdentifier: "shop", sender: sender)
       // self.collectionView.reloadData()t
//        

    }
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCell
        cell.titleLabel.text = books[indexPath.row].title
        
        cell.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
        // Configure the cell
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = books[indexPath.row].id else {return}
        
        API.firebase.fetchQuestion(with: id) { (questions) in
            print(questions)
            API.currentQuestions = questions
            if let vc = self.storyboard!.instantiateViewController(identifier: "MainPageViewController") as? MainPageViewController {
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated:true, completion: nil)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        UIView.animate(withDuration: 0.3) {
//            let color = UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
//            self.view.backgroundColor = color
//            self.collectionView.backgroundColor = color
//        }
        
        }
    
}
