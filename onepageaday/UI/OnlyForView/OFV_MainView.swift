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

    private var currentQuestion:Question?
    
    private var drawingView: PKCanvasView!
    private var drawing: PKDrawing!

    private var indexLabel: UILabel!
    private var questionLabel: UILabel!
    
    //
    
    init(frame: CGRect, currentQuestion: Question) {
        super.init(frame: frame)
        self.currentQuestion = currentQuestion
        
        indexLabel = UILabel(frame: CGRect(x: 0, y: 0, width: Constant.OFV.cellWidth, height: 100))
        questionLabel = UILabel(frame: CGRect(x: 0, y: 100, width: Constant.OFV.cellWidth, height: 100))
        
        
        indexLabel.font = UIFont.systemFont(ofSize: 35 / Constant.OFV.magnification, weight: .bold)
        questionLabel.font = UIFont.systemFont(ofSize: 20 / Constant.OFV.magnification, weight: .bold)
        questionLabel.numberOfLines = 0
        indexLabel.textAlignment = .center
        questionLabel.textAlignment = .center
        
        self.addSubview(indexLabel)
        self.addSubview(questionLabel)
        NSLayoutConstraint.activate([
            indexLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12 / Constant.OFV.magnification),
            indexLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12 / Constant.OFV.magnification),
            indexLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 120 / Constant.OFV.magnification),
            questionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12 / Constant.OFV.magnification),
            questionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12 / Constant.OFV.magnification),
            questionLabel.topAnchor.constraint(equalTo: indexLabel.bottomAnchor, constant: 10 / Constant.OFV.magnification)
        ])
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
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
        self.drawingView.transform = CGAffineTransform(scaleX: 1 / Constant.OFV.magnification, y: 1 / Constant.OFV.magnification)
        self.drawingView.widthAnchor.constraint(equalToConstant: Device.base).isActive = true
        self.drawingView.heightAnchor.constraint(equalToConstant: Device.baseHeight).isActive = true
        self.drawingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.drawingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.drawingView.translatesAutoresizingMaskIntoConstraints = false
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
        let textView = OFV_TextView(frame: CGRect(x: 0, y: 0, width: Device.base, height: Constant.Design.textViewHeight / Constant.OFV.magnification), textViewData: textViewData)
        
        
        return textView
        
        
    }
    
    func makeOFVImageView(imageViewData: ImageViewData) -> OFV_ImageView {
        
        let imageView = OFV_ImageView(
            frame: CGRect(x: self.center.x-50, y: self.center.y-50, width: Constant.Design.imageViewWidth, height: Constant.Design.imageViewHeight),
            imageViewData: imageViewData)
        
        return imageView
        
        
    }
}
