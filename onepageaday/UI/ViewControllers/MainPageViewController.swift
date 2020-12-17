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
    
    var panGesture:UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([createViewController(0)], direction: .forward, animated: false, completion: nil)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss(_:)))
        self.view.addGestureRecognizer(panGesture)

    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    @objc func handleDismiss(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
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

        if (currentIndex <= API.currentQuestions.count-2) {
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
            controller.setValues(question: API.currentQuestions[index], delegate: self)
            controller.createViewsWithData()
            controller.view.backgroundColor = randomColor
            return controller
        }
        return UIViewController()
    }
    
    /// 편집 모드
    func stopScroll() {
        print("stop!")
        self.delegate = nil;
        self.dataSource = nil;
        panGesture.isEnabled = false
    }
    
    /// 뷰 모드
    func startScroll() {
        print("start!")
        self.delegate = self;
        self.dataSource = self;
        panGesture.isEnabled = true
    }
    
}
