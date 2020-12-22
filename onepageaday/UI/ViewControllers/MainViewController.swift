//
//  ViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/08.
//

import UIKit
import PencilKit
import Firebase
import FirebaseFirestoreSwift
//TODO: Model 만들어 사용하기
protocol MainViewControllerDelegate: class {
    func imageViewUpdated(imageViewData: ImageViewData)
    
    func textViewUpdated(textViewData: TextViewData)
    func textViewEditingBegin(textView: EditableTextView)
    func removeTextView(textViewData: TextViewData)
    func textViewEditingEnd()
    
    func getIsEditingTextView()->Bool
    func getIsEditingMode()->Bool
    func getIsDrawing() -> Bool
    
    func drawingBegin()
    func drawingEnd()
    
    func dragBegin()
    func dragEnd(textView: EditableTextView, touchPos: CGPoint)
    func dragEnd(imageView: EditableImageView, touchPos: CGPoint)
    
    func insertSticker(url: String,token:String)
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
            [startDrawButton,addTextViewButton,imageButton,colorWell].forEach({ (btn) in
                if (isEditingMode) {
                    btn?.fadeIn()
                    gradientLayer.isHidden = false
                } else {
                    btn?.fadeOut()
                    gradientLayer.isHidden = true
                }
            })
            if (isEditingMode) {
                //편집모드진입
                showToast(text: "편집 모드")
                pageControllerDelegate?.stopScroll()
                modeToggleButton.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20)), for: .normal)
                
            } else {
                //편집모드종료
                showToast(text: "보기 모드")
                modeToggleButton.setImage(nil, for: .normal)

                
                pageControllerDelegate?.startScroll()
            }
        }
    }
    
    //이름 바꿔
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
    @IBOutlet weak var colorWell: UIColorWell!
    
    //로컬 변수 업데이트시 static에 적용 (구조 수정 필요)
    private var currentQuestion:Question?
    private var currentBookId: String?
    
    let imagePicker = UIImagePickerController()

    private weak var pageControllerDelegate:MainPageViewControllerDelegate?
    
    //ImagePicker
    
    
    deinit {
        print("MainViewController deinit")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        
        setUI()
        
        //편집 모드 진입을 위한 제스처
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(touchRecognized(_:)))
        self.view.addGestureRecognizer(touchRecognizer)
        
        
    }
    
    
    ///생성자라고 생각하면 편함(From MainPageViewController)
    func setValues(question:Question, bookID: String?, delegate: MainPageViewControllerDelegate) {
        self.currentQuestion = question
        self.currentBookId = bookID
        self.pageControllerDelegate = delegate
    }
    
    var gradientLayer: CAGradientLayer = CAGradientLayer()
    //MARK: setUI
    func setUI() {
        //Image Picker
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
        self.imagePicker.allowsEditing = true // 수정 가능 여부
        self.imagePicker.delegate = self // picker delegate
        
        //BackGround ColorWell UI Setting
        colorWell.title = "배경색"
        colorWell.addTarget(self, action: #selector(colorWellValueChanged(_:)), for: .valueChanged)
        colorWell.selectedColor = UIColor(self.currentQuestion?.backGroundColor ?? defaultColor)

        setQuestionText()
        
        
        //배경색
        //self.view.backgroundColor = UIColor(hexString: currentQuestion?.backGroundColor ?? "FFFFFF")
        
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.6).cgColor,
                                    UIColor.black.withAlphaComponent(0.0).cgColor]
        //gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        gradientLayer.locations = [0.07]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.135)
        self.view.layer.addSublayer(gradientLayer)
        gradientLayer.isHidden = true
        
        //뒤로가기 버튼 누르는 범위 늘리기
        self.modeToggleButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 16)
        
        
        //텍스트 관련 UI
        self.darkView = createDarkView()
        self.view.addSubview(darkView)
        
        //self.view.frame = CGRect(x: Device.base.adjusted/2-Device.base/2, y: Device.baseHeight.adjustedHeight/2-Device.baseHeight/2, width: Device.base, height: Device.baseHeight)
        //self.view.transform = CGAffineTransform(scaleX: Device.ratio, y: Device.ratioHeight)
        
        setMenus()
        
        //그림 관련 UI
        
        self.drawingView = PKCanvasView(frame: CGRect.zero)
        self.drawingView.delegate = self
        self.drawingView.alwaysBounceVertical = true
        self.drawingView.drawingPolicy = .anyInput
        self.drawingView.contentInsetAdjustmentBehavior = .never
        self.drawingView.backgroundColor = .clear
        self.drawingView.isUserInteractionEnabled = false
        
        //그림 데이터 불러오기
        self.drawing = try? PKDrawing.init(base64Encoded: self.currentQuestion?.drawings ?? "")
        self.drawingView.drawing = self.drawing ?? PKDrawing()
        
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
        self.drawingView.transform = CGAffineTransform(scaleX: Device.ratio, y: Device.ratioHeight)
        self.drawingView.widthAnchor.constraint(equalToConstant: Device.base).isActive = true
        self.drawingView.heightAnchor.constraint(equalToConstant: Device.baseHeight).isActive = true
        self.drawingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.drawingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        
        
//        self.drawingView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
//        self.drawingView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
//        self.drawingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
//        self.drawingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        self.drawingView.translatesAutoresizingMaskIntoConstraints = false
        
        //버튼 앞으로
        bringButtonsToFront()
        
    }
    
    func setQuestionText() {
        //Question, text set
        if let question = currentQuestion {
            indexLabel.text =
                String(format: "%03d", question.index+1)
            questionLabel.text = question.text
            guard let color = UIColor(self.currentQuestion?.backGroundColor ?? defaultColor) else {return}
            UIView.animate(withDuration: 0.2) { [self] in
                if (color.isLight() == true) {
                    indexLabel.textColor = .black
                    questionLabel.textColor = .black
                } else {
                    indexLabel.textColor = .white
                    questionLabel.textColor = .white
                }
            }
            
        }
    }
    
    //MARK: MENU!
    func setMenus() {
        //스티커 메뉴
        self.imageButton.showsMenuAsPrimaryAction = true
        self.imageButton.menu = UIMenu(title: "스티커",
                                       image: nil,
                                       identifier: nil,
                                       options: .displayInline,
                                       children: [
                                        UIAction(title: "스티커", image: UIImage(systemName: "face.smiling"), handler: { [weak self] _ in
                                          
                                            if let vc = self?.storyboard?.instantiateViewController(identifier: "StickerViewController") as? StickerViewController {
                                                vc.modalPresentationStyle = .formSheet
                                                vc.parentDelegate = self
                                                vc.mode = .sticker
                                                self?.present(vc, animated: true, completion: nil)
                                            }
//                                            self?.createGiphyContent(tag: "행복")
                                       }),
                                        UIAction(title: "GIF", image: UIImage(systemName: "square"), handler: { [weak self] _ in
                                            if let vc = self?.storyboard?.instantiateViewController(identifier: "StickerViewController") as? StickerViewController {
                                                vc.modalPresentationStyle = .formSheet
                                                vc.parentDelegate = self
                                                vc.mode = .gif
                                                self?.present(vc, animated: true, completion: nil)
                                            }
                                       }),
                                        UIAction(title: "사진", image: UIImage(systemName: "photo.on.rectangle.angled"), handler: { [weak self] _ in
                                            if let picker = self?.imagePicker {
                                                self?.present(picker, animated: true, completion: nil)
                                            }
                                            
                                       }),
                                       
                                       ])
    }
    
    //MARK: currentQuestion 활용하여 데이터 생성
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
    
    
    //MARK: modeToggle
    
    //편집 모드 토글
    @IBAction func modeToggleButtonPressed() {
        isEditingMode = !isEditingMode
        
        if (!isEditingMode) { //완료버튼 pressed일 경우 저장 시작
            
            //local 변경
            if let index = API.currentQuestions.firstIndex(where: {$0.id == self.currentQuestion?.id}),let question = currentQuestion {
                API.currentQuestions[index] = question
            }
            
            //network
            API.firebase.updateQuestion(question: currentQuestion, bookID: currentBookId)
        }
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
            
            //print(currentQuestion?.textViewDatas)
            if currentQuestion?.textViewDatas.count == 0 {
                addTextViewButtonPressed()
            } else {
                //TEST
                
                let vc = OFV_MainViewController()
                vc.setValues(question: currentQuestion)
                
                if let bg = currentQuestion?.backGroundColor {
                    vc.view.backgroundColor = UIColor(bg)
                }
                present(vc, animated: true, completion: nil)
            }
            
        }
    }
    
    //그리기 or 텍스트 종료
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if isEditingTextView {
            textViewEditingEnd()
            self.view.endEditing(true)
        }
        if isDrawing {
            drawingEnd()
        }
    }
    
    //MARK: ColorWell
    @objc func colorWellValueChanged(_ sender: Any) {
        self.currentQuestion?.backGroundColor = self.colorWell.selectedColor?.toHexString()
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = UIColor(self.currentQuestion?.backGroundColor ?? defaultColor)
        }
        setQuestionText()
    }
}

//MARK: PKCanvas Delegate
extension MainViewController: PKCanvasViewDelegate {
    
}

//MARK: 스티커 관련 함수들
extension MainViewController: MainViewControllerDelegate {
    func insertSticker(url: String,token:String = "") {
        let data = ImageViewData(center: CGPoint(x: self.view.center.x.reverseAdjusted, y: self.view.center.y.reverseAdjustedHeight), angle: 0, scale: 1.3, imageURL: url, token: token)
        let imageView = self.makeImageView(imageViewData: data)
        
        self.currentQuestion?.imageViewDatas.append(imageView.imageViewData)
        self.view.addSubview(imageView)
        self.view.bringSubviewToFront(imageView)
    }
    
    @IBAction func imageButtonPressed(_ sender: Any) {
//        API.giphyApi.getTrendContents { (json) in
//            let url = json["data"][Int.random(in: 0...20)]["images"]["fixed_width"]["url"].stringValue
//
//            let imageView = self.makeImageView(imageViewData: ImageViewData(center: CGPoint(x: self.view.center.x, y: self.view.center.y), angle: 0, scale: 1, imageURL: url))
//
//            self.currentQuestion?.imageViewDatas.append(imageView.imageViewData)
//            self.view.addSubview(imageView)
//        }
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
        darkView.isHidden=true
        let darkViewTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(darkViewTouchRecognized))
        self.darkView.addGestureRecognizer(darkViewTouchRecognizer)
        
        return darkView
    }
    
    @objc func darkViewTouchRecognized() {
        self.view.endEditing(true)
    }
    
    @IBAction func addTextViewButtonPressed() {
        self.view.bringSubviewToFront(doneButton)
        //let min = a < b ? a : b
        let isLight = UIColor(currentQuestion?.backGroundColor ?? defaultColor)?.isLight()
        let defaultTextColor = isLight ?? true ? "000000" : "FFFFFF"
        
        let editableTextView = makeEditableTextView(textViewData: TextViewData(center: CGPoint(x: (self.view.bounds.width/2).reverseAdjusted, y: (self.view.bounds.height/2).reverseAdjustedHeight), angle: 0, scale: 1, text: "", textColor: defaultTextColor))
        self.view.addSubview(editableTextView)
        editableTextView.becomeFirstResponder()
        
        currentQuestion?.textViewDatas.append(editableTextView.textViewData)
    }
    
    func makeEditableTextView(textViewData: TextViewData) -> EditableTextView {
        let textView = EditableTextView(frame: CGRect(x: self.view.center.x-self.view.bounds.width/2, y: self.view.center.y-50, width: self.view.bounds.width, height: 100), textContainer: nil, parentView: self.view, parentDelegate: self, textViewData: textViewData)
        
        return textView
        
        
    }
}

//MARK: 이미지관련함수
extension MainViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                //token create
                let token = UUID().uuidString
                
                //Firebase upload
                API.firebase.uploadImage(image: image, token: token) { (url) in
                    print(url)
                    self.insertSticker(url: url, token: token)
                }
                
                //url create
                
                //insertSticker
                
            }
            
        
            picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
            
    }
}


//MARK: DELEGATE ( 뷰와의 상호작용 )
extension MainViewController {
    func removeTextView(textViewData: TextViewData) {
        if let index = currentQuestion?.textViewDatas.firstIndex(where: {$0.token == textViewData.token}) {
            self.currentQuestion?.textViewDatas.remove(at: index)
            
        }
    }
    /// 드래그 종료, 삭제 필요시 삭제
    func dragEnd(textView: EditableTextView, touchPos: CGPoint) {
        if !isEditingTextView { //조금 드래그하면 편집과 동시에 움직여짐 방지
            showViews([modeToggleButton,addTextViewButton,startDrawButton,imageButton,colorWell])
        }
        let size:CGFloat = 40.0
        let touchArea = CGRect(x: touchPos.x-size/2, y: touchPos.y-size/2, width: size, height: size)
        
        if (touchArea.intersects(self.trashView.frame)) {
            if let index = currentQuestion?.textViewDatas.firstIndex(where: { $0.token == textView.textViewData.token }){
                currentQuestion?.textViewDatas.remove(at: index )
                textView.removeFromSuperview()
            }
            
        }
        self.trashView.fadeOut()
        
        //z-index 바꾸기(제일 앞으로)
        if let index = currentQuestion?.textViewDatas.firstIndex(where: {$0.token == textView.textViewData.token}), let length = currentQuestion?.textViewDatas.count  {
            currentQuestion?.textViewDatas.move(at: index, to: length-1)
        }
        
    }
    
    /// 드래그 종료, 삭제 필요시 삭제
    func dragEnd(imageView: EditableImageView, touchPos: CGPoint) {
        showViews([modeToggleButton,addTextViewButton,startDrawButton,imageButton,colorWell])
        let size:CGFloat = 40.0
        let touchArea = CGRect(x: touchPos.x-size/2, y: touchPos.y-size/2, width: size, height: size)
        
        if (touchArea.intersects(self.trashView.frame)) {
            if let index = currentQuestion?.imageViewDatas.firstIndex(where: { $0.token == imageView.imageViewData.token }){
                
                currentQuestion?.imageViewDatas.remove(at: index )
                imageView.removeFromSuperview()
            }
            
            //Storage일 경우 이미지 삭제 필요
            if (API.firebase.isFireBaseStorageLink(url: imageView.imageViewData.imageURL)) {
                API.firebase.deleteImage(token: imageView.imageViewData.token)
            }
        }
        
        
        
        self.trashView.fadeOut()
        
        //z-index 바꾸기(제일 앞으로)=
        if let index = currentQuestion?.imageViewDatas.firstIndex(where: {$0.token == imageView.imageViewData.token}), let length = currentQuestion?.imageViewDatas.count  {
            currentQuestion?.imageViewDatas.move(at: index, to: length-1)
        }
    }
    
    ///드래그 시작,  삭제뷰 생성
    func dragBegin() {
        hideViews([modeToggleButton,addTextViewButton,startDrawButton,imageButton,colorWell])
        self.view.bringSubviewToFront(trashView)
        trashView.fadeIn()
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
        
        hideViews([modeToggleButton,addTextViewButton,colorWell,startDrawButton,imageButton])
        showViews([doneButton,darkView])
        
        
        self.view.bringSubviewToFront(self.darkView)
        self.view.bringSubviewToFront(self.doneButton)
        self.view.bringSubviewToFront(textView)
    }
    
    func textViewEditingEnd() {
        isEditingTextView = false
        //빈 텍스트 버리기
        
        hideViews([doneButton,darkView])
        showViews([imageButton,modeToggleButton,colorWell,addTextViewButton,startDrawButton,imageButton])
    }
    
    func drawingBegin() {
        isDrawing = true
        showToast(text: "그리기 시작")
        
        hideViews([addTextViewButton,modeToggleButton,colorWell,imageButton,startDrawButton])
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
        
        self.currentQuestion?.drawings = self.drawingView.drawing.base64EncodedString()
        
        
        hideViews([doneButton])
        showViews([imageButton,modeToggleButton,colorWell,addTextViewButton,startDrawButton])
        
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
        self.view.bringSubviewToFront(colorWell)
    }
    
    func hideViews(_ views: [UIView]) {
        views.forEach {
            $0.isHidden = true
        }
        gradientLayer.isHidden = true

    }
    
    func showViews(_ views: [UIView]) {
        views.forEach {
            $0.isHidden = false
        }
        gradientLayer.isHidden = false

    }
    
    
}



