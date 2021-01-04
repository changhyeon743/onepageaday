//
//  PurchasePageViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2021/01/04.
//

import UIKit

struct PurchaseItem {
    var title: String
    var detail: String
    var imageLink: String
}

class PurchasePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var purchaseItemList:[PurchaseItem]?
    
    var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        purchaseItemList?.forEach { item in
            if let vc = storyboard?.instantiateViewController(identifier: "PurchaseViewController") as? PurchaseViewController {
                vc.item = item
                pages.append(vc)
            }
        }

        // etc ...
        if let first = pages.first {
            setViewControllers([first], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController)-> UIViewController? {
       
        let cur = pages.firstIndex(of: viewController)!

        // if you prefer to NOT scroll circularly, simply add here:
        // if cur == 0 { return nil }

        var prev = (cur - 1) % pages.count
        if prev < 0 {
            prev = pages.count - 1
        }
        return pages[prev]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController)-> UIViewController? {
         
        let cur = pages.firstIndex(of: viewController)!

        // if you prefer to NOT scroll circularly, simply add here:
        // if cur == (pages.count - 1) { return nil }

        let next = abs((cur + 1) % pages.count)
        return pages[next]
    }

    func presentationIndex(for pageViewController: UIPageViewController)-> Int {
        return pages.count
    }
    
}
