//
//  ViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/08.
//

import UIKit
import PencilKit
import Firebase

protocol MainViewControllerDelegate {
    func imageViewUpdated(imageViewData: ImageViewData)
    
    func textViewUpdated(textViewData: TextViewData)
    func textViewEditingBegin(textView: EditableTextView)
    func textViewEditingEnd()
    
    
    func getIsEditingTextView()->Bool
    func getIsEditingMode()->Bool
    func getIsDrawing() -> Bool
    
    func drawingBegin()
    func drawingEnd()
    
    func dragBegin()
    func dragEnd(textView: EditableTextView, touchPos: CGPoint)
    func dragEnd(imageView: EditableImageView, touchPos: CGPoint)
}

class MainViewController: UIViewController {
    //public because of pageviewcontroller
    public var currentIndex:Int = 0
    
    //if Edit Mode ON
    private var isEditingTextView:Bool = false
    private var isDrawing:Bool = false
    
    //Edit Mode
    private var isEditingMode:Bool = false {
        didSet {
            startDrawButton.isHidden = !isEditingMode
            addTextViewButton.isHidden = !isEditingMode
            imageButton.isHidden = !isEditingMode

            if (isEditingMode) {
                //편집모드진입
                showToast(text: "편집 모드")
                pageControllerDelegate?.stopScroll()
                modeToggleButton.setImage(UIImage(systemName: "checkmark.square", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24)), for: .normal)
                modeToggleButton.setTitle("완료", for: .normal)
                
            } else {
                //편집모드종료
                showToast(text: "보기 모드")
                modeToggleButton.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24)), for: .normal)
                modeToggleButton.setTitle("편집", for: .normal)

                
                pageControllerDelegate?.startScroll()
            }
        }
    }
    
    @IBOutlet weak var modeToggleButton:UIButton!
    @IBOutlet weak var addTextViewButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var startDrawButton: UIButton!
    /// DRAWING 변수
    private var drawingView: PKCanvasView!
    private var drawing: PKDrawing!
    private var toolPicker: PKToolPicker!
    /// END
    private var darkView: UIView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var trashView: UIImageView!
    
    //로컬 변수 업데이트시 static에 적용 (구조 수정 필요)
    private var currentQuestion:Question? {
        didSet {
            if let index = API.currentQuestions.firstIndex(where: { $0.id == currentQuestion?.id }), let question = currentQuestion {
                API.currentQuestions[index] = question
            }
        }
    }
    
    private var pageControllerDelegate:MainPageViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let question = currentQuestion {
            indexLabel.text =
                String(format: "%03d", question.index+1)
            questionLabel.text = question.text
        }
        
        setUI()
        
        //편집 모드 진입을 위한 제스처
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchRecognized(_:)))
        self.view.addGestureRecognizer(touchRecognizer)
        
    }
    
    //MARK: setUI
    func setUI() {
        //텍스트 관련 UI
        self.darkView = createDarkView()
        self.view.addSubview(darkView)
        
        
        //그림 관련 UI
        self.drawingView = PKCanvasView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        self.drawingView.delegate = self
        self.drawingView.alwaysBounceVertical = true
        self.drawingView.drawingPolicy = .anyInput
        self.drawingView.backgroundColor = .clear
        self.drawingView.isUserInteractionEnabled = false
        
        //그림 데이터 불러오기
        self.drawing = self.currentQuestion?.drawings ?? PKDrawing()
        self.drawingView.drawing = self.drawing
        
        //그림 ToolPicker
        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            let window = parent?.view.window
            toolPicker = PKToolPicker.shared(for: window!)
        }
        toolPicker.setVisible(false, forFirstResponder: drawingView)
        toolPicker.addObserver(drawingView)
        
        updateLayout(for: toolPicker)
        drawingView.becomeFirstResponder()
        
        
        //need to place onn createViewWithData but here.. ( need to fix )
        self.view.addSubview(drawingView)
        
        //버튼 앞으로
        bringButtonsToFront()
    }
    
    //currentQuestion 활용하여 데이터 생성
    func createViewsWithData() {
        //텍스트
        currentQuestion?.textViewDatas.forEach{
            self.view.addSubview(makeEditableTextView(textViewData: $0))
            
        }
        
        //이미지
        currentQuestion?.imageViewDatas.forEach{
            self.view.addSubview(makeImageView(imageViewData: $0))
            
        }
        
    }
    
    func setValues(question:Question, delegate: MainPageViewControllerDelegate) {
        self.currentQuestion = question
        self.pageControllerDelegate = delegate
    }
    
    
    
    //편집 모드 토글
    @IBAction func modeToggleButtonPressed() {
        isEditingMode.toggle()
    }
    
    //터치로 편집모드진입
    @objc func touchRecognized(_ recognizer: UITapGestureRecognizer) {
        if (!self.isEditingMode) {
            self.isEditingMode = true
        } else { //그리기 모드도 아닐 경우 취소
//            if (!isDrawing && !isEditingTextView) {
//                self.isEditingMode = false
//            }
            //텍스트 한 개도 없을 경우?
            if currentQuestion?.textViewDatas.count == 0 {
                let editableTextView = makeEditableTextView(textViewData: TextViewData(center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2), angle: 0, scale: 1, text: "") )
                self.view.addSubview(editableTextView)
                editableTextView.becomeFirstResponder()
                
                currentQuestion?.textViewDatas.append(editableTextView.textViewData)
            }
            
        }
    }
    
    //그리기 or 텍스트 종료
    @IBAction func doneButtonPressed(_ sender: Any) {
        do {
            try Firestore.firestore().collection("questions").document("LA").setData(from: currentQuestion)
        } catch let error {
            print("Error writing city to Firestore: \(error)")
        }
        if isEditingTextView {
            textViewEditingEnd()
            self.view.endEditing(true)
        }
        if isDrawing {
            drawingEnd()
        }
    }
}

//MARK: PKCanvas Delegate
extension MainViewController: PKCanvasViewDelegate {
    
}

//MARK: 스티커 관련 함수들
extension MainViewController: MainViewControllerDelegate {
    @IBAction func imageButtonPressed(_ sender: Any) {
        API.giphyApi.getTrendContents { (json) in
            
            let url = json["data"][Int.random(in: 0...20)]["images"]["fixed_width"]["url"].stringValue
            
            let imageView = self.makeImageView(imageViewData: ImageViewData(center: CGPoint(x: self.view.center.x, y: self.view.center.y), angle: 0, scale: 1, imageURL: url))
            
            self.currentQuestion?.imageViewDatas.append(imageView.imageViewData)
            self.view.addSubview(imageView)
        }
    }
    
    func makeImageView(imageViewData: ImageViewData) -> EditableImageView {
        let imageView = EditableImageView(
            frame: CGRect(x: self.view.center.x-50, y: self.view.center.y-50, width: 100, height: 100),
            parentView: self.view,
            parentDelegate: self, imageViewData: imageViewData)
        
        return imageView
        
        
    }
    
}


//MARK: 그림 관련 함수들
extension MainViewController {
    
    @IBAction func drawingButtonPressed(_ sender: Any) {
        self.drawingBegin()
    }
    
    func updateLayout(for toolPicker: PKToolPicker) {
        
    }
}


//MARK: 편집용텍스트 관련 함수들
extension MainViewController {
    func createDarkView() -> UIView {
        darkView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        darkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45)
        darkView.isHidden = true
        let darkViewTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(darkViewTouchRecognized))
        self.darkView.addGestureRecognizer(darkViewTouchRecognizer)
        
        return darkView
    }
    
    @objc func darkViewTouchRecognized() {
        self.view.endEditing(true)
    }
    
    @IBAction func addTextViewButtonPressed() {
        self.view.bringSubviewToFront(doneButton)
        
        
        let editableTextView = makeEditableTextView(textViewData: TextViewData(center: CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2), angle: 0, scale: 1, text: "") )
        self.view.addSubview(editableTextView)
        editableTextView.becomeFirstResponder()
        
        currentQuestion?.textViewDatas.append(editableTextView.textViewData)
    }
    
    func makeEditableTextView(textViewData: TextViewData) -> EditableTextView {
        let textView = EditableTextView(frame: CGRect(x: self.view.center.x-self.view.bounds.width/2, y: self.view.center.y-50, width: self.view.bounds.width, height: 100), textContainer: nil, parentView: self.view, parentDelegate: self, textViewData: textViewData)
        textView.textColor = UIColor.label
        textView.backgroundColor = .none
        textView.font = UIFont.systemFont(ofSize: 40)
        textView.textAlignment = .center
        
        
        return textView
        
        
    }
}


//MARK: DELEGATE ( 뷰와의 상호작용 )
extension MainViewController {
    /// 드래그 종료, 삭제 필요시 삭제
    func dragEnd(textView: EditableTextView, touchPos: CGPoint) {
        let size:CGFloat = 40.0
        let touchArea = CGRect(x: touchPos.x-size/2, y: touchPos.y-size/2, width: size, height: size)
        
        if (touchArea.intersects(self.trashView.frame)) {
            if let index = currentQuestion?.textViewDatas.firstIndex(where: { $0.token == textView.textViewData.token }){
                currentQuestion?.textViewDatas.remove(at: index )
                textView.removeFromSuperview()
            }
            
        }
        self.trashView.isHidden = true
    }
    
    /// 드래그 종료, 삭제 필요시 삭제
    func dragEnd(imageView: EditableImageView, touchPos: CGPoint) {
        let size:CGFloat = 40.0
        let touchArea = CGRect(x: touchPos.x-size/2, y: touchPos.y-size/2, width: size, height: size)
        
        if (touchArea.intersects(self.trashView.frame)) {
            if let index = currentQuestion?.imageViewDatas.firstIndex(where: { $0.token == imageView.imageViewData.token }){
                currentQuestion?.imageViewDatas.remove(at: index )
                imageView.removeFromSuperview()
            }
        }
        
        self.trashView.isHidden = true
    }
    
    ///드래그 시작,  삭제뷰 생성
    func dragBegin() {
        self.view.bringSubviewToFront(trashView)
        trashView.isHidden = false
        self.trashView.transform = CGAffineTransform(scaleX: 0, y: 0)

        UIView.animate(withDuration: 0.2,
            animations: {
                self.trashView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.trashView.transform = CGAffineTransform.identity
                }
            })
    }
    
    
    //이미지데이터 업데이트
    func imageViewUpdated(imageViewData: ImageViewData) {
        bringButtonsToFront()
        
        if let index = currentQuestion?.imageViewDatas.firstIndex(where: { $0.token == imageViewData.token }){
            currentQuestion?.imageViewDatas[index] = imageViewData
        }
    }
        
    //텍스트데이터 업데이트
    func textViewUpdated(textViewData: TextViewData) {
        bringButtonsToFront()
        
        if let index = currentQuestion?.textViewDatas.firstIndex(where: { $0.token == textViewData.token }){
            currentQuestion?.textViewDatas[index] = textViewData
        }
    }
    
    
    //현재 상태 반환
    func getIsEditingTextView() -> Bool {return self.isEditingTextView }
    func getIsDrawing() -> Bool { return self.isDrawing }
    func getIsEditingMode() -> Bool { return self.isEditingMode }
    
    
    func textViewEditingBegin(textView: EditableTextView) {
        isEditingTextView = true
        
        hideViews([modeToggleButton,addTextViewButton,startDrawButton,imageButton])
        showViews([doneButton,darkView])
        
        self.view.bringSubviewToFront(self.darkView)
        self.view.bringSubviewToFront(self.doneButton)
        self.view.bringSubviewToFront(textView)
    }
    
    func textViewEditingEnd() {
        isEditingTextView = false
        
        hideViews([doneButton,darkView])
        showViews([imageButton,modeToggleButton,addTextViewButton,startDrawButton,imageButton])
    }
    
    func drawingBegin() {
        isDrawing = true
        showToast(text: "그리기 시작")
        
        hideViews([addTextViewButton,modeToggleButton,imageButton,startDrawButton])
        showViews([doneButton])
        
        self.drawingView.isUserInteractionEnabled = true
        toolPicker.setVisible(true, forFirstResponder: drawingView)
        toolPicker.addObserver(drawingView)
        
        updateLayout(for: toolPicker)
        drawingView.becomeFirstResponder()
    }
    
    func drawingEnd() {
        isDrawing = false
        showToast(text: "그리기 완료")
        
        self.currentQuestion?.drawings = self.drawingView.drawing
        
        hideViews([doneButton])
        showViews([imageButton,modeToggleButton,addTextViewButton,startDrawButton])
        
        self.drawingView.isUserInteractionEnabled = false
        toolPicker.setVisible(false, forFirstResponder: drawingView)
    }
}
//MARK: Fixing UI Problems
extension MainViewController {
    func bringButtonsToFront() {
        self.view.bringSubviewToFront(imageButton)
        self.view.bringSubviewToFront(modeToggleButton)
        self.view.bringSubviewToFront(doneButton)
        self.view.bringSubviewToFront(startDrawButton)
        self.view.bringSubviewToFront(addTextViewButton)
    }
    
    func hideViews(_ views: [UIView]) {
        views.forEach { (v) in
            v.isHidden = true
        }
    }
    
    func showViews(_ views: [UIView]) {
        views.forEach { (v) in
            v.isHidden = false
        }
    }
}


//Toast Message
extension UIViewController {
    func showToast(text: String) {
        
        let label = UILabel(frame: CGRect(x: self.view.bounds.width/2-65, y: self.view.bounds.height - 25-150, width: 130, height: 30))
        
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        
        self.view.addSubview(label)
        
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 7
        label.clipsToBounds = true
        
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut) {
            label.alpha = 0
        } completion: { (complete) in
            label.removeFromSuperview()
        }
        
    }
}
