//
//  MainPageViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/10.
//

import UIKit
import Kingfisher
import FirebaseFirestore

protocol MainPageViewControllerDelegate: class{
    func stopScroll()
    func startScroll()
    
    func setViewControllerIndex(index:Int)
    func dismissAndSave()
    //DrawingView UI Problem FIX
}

class MainPageViewController: UIPageViewController,UIPageViewControllerDelegate, UIPageViewControllerDataSource,MainPageViewControllerDelegate {
    
    
    var book:Book?
    var currentIndex:Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {

        
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([createViewController(currentIndex)], direction: .forward, animated: false, completion: nil)
        
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
            return UIColor(Constant.Design.backGroundColors.randomElement() ?? defaultColor)!
        }
        if let storyboard = self.storyboard {
            let controller = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            if API.currentQuestions.count >= 1 {
                controller.currentIndex = index
                controller.setValues(question: API.currentQuestions[index],bookID: book?.id, delegate: self)
                
                if let bg = API.currentQuestions[index].backGroundColor {
                    controller.view.backgroundColor = UIColor(bg)
                    print(bg)
                } else {
                    controller.view.backgroundColor = randomColor
                }
                
                controller.createViewsWithData()
                
            }
            return controller
        }
        return UIViewController()
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed && finished) {
            if let vc = pageViewController.viewControllers?.first as? MainViewController {
                if vc.currentIndex == API.currentQuestions.count-1 {
                    self.showToast(text: "마지막 페이지")
                }
                book?.currentIndex = vc.currentIndex
            }
            
        }
    }
    /// 편집 모드
    func stopScroll() {
        print("stop!")
        self.delegate = nil;
        self.dataSource = nil;
    }
    
    /// 뷰 모드
    func startScroll() {
        print("start!")
        self.delegate = self;
        self.dataSource = self;
    }
    
    func setViewControllerIndex(index: Int) {
        self.currentIndex = index
        book?.currentIndex = currentIndex
        self.setViewControllers([createViewController(currentIndex)], direction: .forward, animated: false, completion: nil)
        startScroll()

    }
    
    func dismissAndSave() {
        book?.modifiedDate = Date()
        API.firebase.updateBook(book: book)
        dismiss(animated: true, completion: nil)
    }
    
    
    deinit {
        //메모리 누수 방지
        
        API.currentQuestions = []
//        print("MainPageViewController deinited")
    }
    
}
