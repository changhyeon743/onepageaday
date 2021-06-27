//
//  OFV_MainViewController.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/20.
//

import UIKit
import PencilKit


///OFV = Only For View , 메모리 누수 최소화 목표위해 코드 재작성. touch Recognizer 등등 배제
//시간 되면 다시 만들기..!
class OFV_MainView: UIView, PKCanvasViewDelegate {

    public var currentQuestion:Question?
    
    private var drawingView: PKCanvasView!
    private var drawing: PKDrawing!

    private var indexLabel: UILabel!
    public var questionLabel: UILabel!
    
    private var _magnification: CGFloat? = 1
    public var magnification: CGFloat {
        return _magnification ?? Constant.OFV.magnification
    }
    
    //
    
    init(frame: CGRect, currentQuestion: Question, _magnification: CGFloat? = 1) {
        super.init(frame: frame)
        self.currentQuestion = currentQuestion
        self._magnification = _magnification
        indexLabel = UILabel(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: 100))
        questionLabel = UILabel(frame: CGRect(x: 0, y: 100, width: Constant.OFV.cellWidth, height: 100))
        
        
        indexLabel.font = .cafe(size: 35 / magnification)
            //UIFont.systemFont(ofSize: 35 / magnification, weight: .bold)
        questionLabel.font = .cafe(size: 20 / magnification)
            //UIFont.systemFont(ofSize: 20 / magnification, weight: .bold)
        questionLabel.numberOfLines = 0
        indexLabel.textAlignment = .center
        questionLabel.textAlignment = .center
        
        self.addSubview(indexLabel)
        self.addSubview(questionLabel)
        indexLabel.snp.makeConstraints{
            $0.left.right.equalToSuperview().inset(12/magnification)
            $0.top.equalToSuperview().inset(75 / magnification)
        }
        questionLabel.snp.makeConstraints{
            $0.right.left.equalToSuperview().inset(12/magnification)
            $0.top.equalTo(self.indexLabel.snp.bottom).offset(5/magnification)
        }
        
        setQuestionText()
        setUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func setUI() {
        self.clipsToBounds = true
        
        self.drawingView = PKCanvasView(frame: CGRect.zero)
        self.drawingView.delegate = self
        self.drawingView.alwaysBounceVertical = true
        self.drawingView.drawingPolicy = .anyInput
        self.drawingView.backgroundColor = .clear
        self.drawingView.isUserInteractionEnabled = false
        self.addSubview(drawingView)
        self.drawingView.transform = CGAffineTransform(scaleX: 1 / magnification, y: 1 / magnification)
        self.drawingView.snp.makeConstraints{
            $0.width.equalTo(Device.base)
            $0.height.equalTo(Device.baseHeight)
            $0.centerX.centerY.equalToSuperview()
        }
        self.drawingView.drawing =  (try? PKDrawing.init(base64Encoded: self.currentQuestion?.drawings ?? "")) ?? PKDrawing()
        
        createViewsWithData()
        
    }
    
    func setValues(question: Question?) {
        self.currentQuestion = question
    }
    
    func createViewsWithData() {
        //텍스트
        currentQuestion?.textViewDatas.forEach{
            let tv = makeOFVTextView(textViewData: $0)
            
            self.addSubview(tv)
            
        }
        
        //이미지
        currentQuestion?.imageViewDatas.forEach{
            self.addSubview(makeOFVImageView(imageViewData: $0))
        }
        
    }
    
    func makeOFVTextView(textViewData: TextViewData) -> OFV_TextView {
        
        //BASE는 기본으로 가져가고 후에 Scale로 조절
        let textView = OFV_TextView(frame: CGRect(x: 0, y: 0, width: Device.base, height: Constant.Design.textViewHeight / magnification), textViewData: textViewData, magnification: magnification)
        
        
        return textView
        
        
    }
    
    func makeOFVImageView(imageViewData: ImageViewData) -> OFV_ImageView {
        
        let imageView = OFV_ImageView(
            frame: CGRect(x: self.center.x-50, y: self.center.y-50, width: Constant.Design.imageViewWidth, height: Constant.Design.imageViewHeight),
            imageViewData: imageViewData, magnification: magnification)
        
        return imageView
        
        
    }
}
