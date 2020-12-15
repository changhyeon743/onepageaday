//
//  BookSelectingViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/11.
//

import UIKit

private let reuseIdentifier = "cell"



class BookSelectingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView:UICollectionView!
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
        // Configure the cell
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard!.instantiateViewController(identifier: "MainPageViewController") as? MainPageViewController {
            
            self.presentPanModal(vc)
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
