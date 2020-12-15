//
//  MainPageViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import UIKit

protocol MainPageViewControllerDelegate{
    func stopScroll()
    func startScroll()
}

class MainPageViewController: UIPageViewController,UIPageViewControllerDelegate, UIPageViewControllerDataSource,MainPageViewControllerDelegate {
   
    
    
    
    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([createViewController(0)], direction: .forward, animated: false, completion: nil)
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = (viewController as! MainViewController).currentIndex
        if (currentIndex > 0) {
            let controller = createViewController(currentIndex-1)
            return controller
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = (viewController as! MainViewController).currentIndex

        if (currentIndex <= API.questions.count-2) {
            let controller = createViewController(currentIndex+1)
            return controller
        }
        return nil
    }

    func createViewController(_ index: Int) -> UIViewController {
        var randomColor: UIColor {
            return UIColor(hue: CGFloat(arc4random_uniform(360))/360, saturation: 0.5, brightness: 0.8, alpha: 1)
        }
        if let storyboard = self.storyboard {
            let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            controller.currentIndex = index
            controller.setValues(question: API.questions[index], delegate: self)
            controller.createViewsWithData()
            controller.view.backgroundColor = randomColor
            return controller
        }
        return UIViewController()
    }
    
    func stopScroll() {
        print("stop!")
        self.delegate = nil;
        self.dataSource = nil;
    }
    
    func startScroll() {
        print("start!")
        self.delegate = self;
        self.dataSource = self;
    }
}
