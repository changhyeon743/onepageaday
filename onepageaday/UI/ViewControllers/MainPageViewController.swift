//
//  MainPageViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import UIKit
import Kingfisher

protocol MainPageViewControllerDelegate: class{
    func stopScroll()
    func startScroll()
    
    //DrawingView UI Problem FIX
}

class MainPageViewController: UIPageViewController,UIPageViewControllerDelegate, UIPageViewControllerDataSource,MainPageViewControllerDelegate {
    
    
    var panGesture:UIPanGestureRecognizer!
    
    var book:Book?
    var currentIndex:Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {

        
        self.dataSource = self
        self.delegate = self
                
        self.setViewControllers([createViewController(currentIndex)], direction: .forward, animated: false, completion: nil)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGesture)
        
    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            if (self.viewTranslation.y > 0) {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
            }
            
        case .ended:
            if viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            } else {
//                if let index = API.books.firstIndex(where: {$0.id == self.book?.id}) {
//                    API.books[index].currentIndex = 0
//                }
                book?.modifiedDate = Date()
                API.firebase.updateBook(book: book)
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
    
    override func viewSafeAreaInsetsDidChange() {
//        print("viewSafeAreaInsetsDidChange")
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
            if API.currentQuestions.count >= 1 {
                controller.currentIndex = index
                controller.setValues(question: API.currentQuestions[index],bookID: book?.id, delegate: self)
                
                controller.createViewsWithData()
                
                if let bg = API.currentQuestions[index].backGroundColor {
                    controller.view.backgroundColor = UIColor(bg)
                    print(bg)
                } else {
                    controller.view.backgroundColor = randomColor
                }
                
            }
            return controller
        }
        return UIViewController()
    }
    
    var tempCurrentIndex = 0
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed && finished) {
            //오른으로 움직였는가?
            if let vc = pageViewController.viewControllers?.first as? MainViewController {
                book?.currentIndex = vc.currentIndex
            }
            
        }
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
    
    
    
    deinit {
        //메모리 누수 방지
        
        API.currentQuestions = []
//        print("MainPageViewController deinited")
    }
    
}
