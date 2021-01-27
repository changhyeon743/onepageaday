//
//  ThemeIndexViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/26.
//

import UIKit
import Firebase
import SkeletonView

protocol ThemeIndexViewControllerDelegate : class {
    func save(uiimage: UIImage)
    func report(questionId: String)
}

//오늘의 매일력 / 기타 등등
//TODO: Skeleton
class ThemeIndexViewController: UIViewController , SkeletonCollectionViewDelegate, SkeletonCollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching,ThemeIndexViewControllerDelegate {
    lazy var activityIndicator: UIActivityIndicatorView = { return makeActivityIndicator(center: self.view.center) }()
    
    
    
    enum Theme:Int {
        case titleSearch, today
    }
    
    var theme: Theme? = .today
    var lastDocument: DocumentSnapshot?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var items: [Question]?
    
    var date:Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)

        
        if (theme == .today) {
            setTitleToDate()
        } else {
            //이전 다음 비활성화
            backButton.removeFromSuperview()
            nextButton.removeFromSuperview()
        }
        fetchData()
        titleLabel.text = title
        let gesture = UITapGestureRecognizer(target: self, action: #selector(callDatePicker))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(gesture)

    }
    var blurEffectView:UIVisualEffectView!
    var datePicker:UIDatePicker!
    @objc func callDatePicker() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(blurEffectView)
        datePicker = UIDatePicker()
        datePicker.date = self.date
        datePicker.datePickerMode = .date
        datePicker.locale = .current
        datePicker.preferredDatePickerStyle = UIDatePickerStyle.inline
        datePicker.addAction(UIAction(handler: { [weak self] (action) in
            self?.date = self?.datePicker.date ?? Date()
            self?.fetchData()
            self?.setTitleToDate()
            self?.datePicker.removeFromSuperview()
            self?.blurEffectView.removeFromSuperview()
        }), for: .valueChanged)
        
       
        self.view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.bringSubviewToFront(datePicker)
        
        blurEffectView?.isUserInteractionEnabled = true
        blurEffectView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDatePicker)))
    }
    @objc func dismissDatePicker() {
        datePicker.removeFromSuperview()
        blurEffectView.removeFromSuperview()
    }
    
    func setTitleToDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy년 MM월 dd일의 매일력"
        
        self.title = dateFormatter.string(from: date)
        titleLabel.text = title
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "cell"
    }
    
    @IBAction func beforeButtonPressed(_ sender: Any) {
        date = date.dayBefore
        fetchData()
        setTitleToDate()
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        if (date.dayAfter.timeIntervalSince1970 < Date().timeIntervalSince1970) {
            date = date.dayAfter
            fetchData()
            setTitleToDate()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let items = self.items {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThemeCollectionViewCell
            let view = OFV_MainView(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: Constant.OFV.cellHeight),currentQuestion: items[indexPath.row])
            
            if let bg = items[indexPath.row].backGroundColor {
                view.backgroundColor = UIColor(bg)
            }
            
            cell.id = items[indexPath.row].id
            cell.parentDelegate = self
            cell.stopSkeletonAnimation()
            cell.ofv_mainView = view
            
            
            let interaction = UIContextMenuInteraction(delegate: cell)
            cell.addInteraction(interaction)
            cell.isUserInteractionEnabled = true
            
            cell.addSubview(cell.ofv_mainView ?? UIView())
            cell.ofv_mainView?.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            cell.ofv_mainView?.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            cell.ofv_mainView?.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            cell.ofv_mainView?.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            cell.ofv_mainView?.translatesAutoresizingMaskIntoConstraints = false
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ThemeCollectionViewCell
            cell.showAnimatedGradientSkeleton()
            return cell
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let items = self.items else {return}
        for indexPath in indexPaths {
            print(indexPath.row)
            if items.count == items.count - indexPath.row { //Don't know why...
              print("ADD DATA")
                addData()
            }
        }
    }
    
    func fetchData() {
        self.activityIndicator.startAnimating()
        if (self.theme == Theme.today) {
            API.firebase.fetchQuestion(withDate: date,after: nil) { (questions,lastDocument)  in
                self.items = questions
                self.collectionView.reloadData()
                self.lastDocument = lastDocument
                self.activityIndicator.stopAnimating()
                self.noResult()
            }
        } else if (self.theme == Theme.titleSearch){
            API.firebase.fetchQuestion(withName: self.title ?? "", after: nil) { (questions,lastDocument)  in
                self.items = questions
                self.collectionView.reloadData()
                self.lastDocument = lastDocument
                self.noResult()
                self.activityIndicator.stopAnimating()
            }
        }
        
    }
    func noResult() {
        if (self.items?.count == 0) {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.width, height: self.collectionView.bounds.height))
            let label = UILabel(frame: CGRect(x: 12, y: 12, width: 100, height: 50))
            label.text = "검색결과 없음"
            label.textColor = .label
            view.addSubview(label)
            self.collectionView.backgroundView = view
        } else {
            self.collectionView.backgroundView = nil
        }
    }
    
    func addData() {
        if let last = lastDocument {
            activityIndicator.startAnimating()
            if (self.theme == Theme.today) {
                API.firebase.fetchQuestion(withDate:date,after: last) { (questions,lastDocument)  in
                    self.activityIndicator.stopAnimating()
                    self.items?.append(contentsOf: questions)
                    self.collectionView.reloadData()
                    
                    self.lastDocument = lastDocument
                }
            } else if (self.theme == Theme.titleSearch) {
                API.firebase.fetchQuestion(withName: self.title ?? "", after: nil) { (questions,lastDocument)  in
                    self.activityIndicator.stopAnimating()
                    self.items?.append(contentsOf: questions)
                    self.collectionView.reloadData()
                    self.lastDocument = lastDocument
                }
            }
            
        } else {
            print("이미 마지막")
        }
    }
    
    func save(uiimage: UIImage) {
        UIImageWriteToSavedPhotosAlbum(uiimage, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func report(questionId: String) {
        let actionSheet = UIAlertController(title: "신고 사유 선택", message: nil, preferredStyle: .actionSheet)
        ["상업적 광고 및 판매","정당/정치인 비하 및 선거운동","욕설/비하","놀람/도배","음란물"].forEach { (title) in
            actionSheet.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                API.firebase.addReport(questionId: questionId, content: title) {
                    let alert = UIAlertController(title: "신고가 완료되었습니다.", message: "검토 후에 적절한 처리가 이루어질 예정입니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
        }
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                // we got back an error!
                print(error.localizedDescription)
            } else {
                print("saved")
                let alert = UIAlertController(title: "갤러리에 저장", message: "갤러리에 저장되었습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
}
