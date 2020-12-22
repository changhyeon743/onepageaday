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
class OFV_MainViewController: UIViewController, PKCanvasViewDelegate {

    private var currentQuestion:Question?
    
    private var drawingView: PKCanvasView!
    private var drawing: PKDrawing!

    private var indexLabel: UILabel!
    private var questionLabel: UILabel!
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        indexLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        questionLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 200, height: 100))
        
        
        indexLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        questionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        indexLabel.textAlignment = .center
        questionLabel.textAlignment = .center
        
        self.view.addSubview(indexLabel)
        self.view.addSubview(questionLabel)
        NSLayoutConstraint.activate([
            indexLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 12),
            indexLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 12),
            indexLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 169),
            questionLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 12),
            questionLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 12),
            questionLabel.topAnchor.constraint(equalTo: indexLabel.bottomAnchor, constant: 10)
        ])
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setQuestionText()
        setUI()
        // Do any additional setup after loading the view.
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
        self.view.clipsToBounds = true
        
        self.drawingView = PKCanvasView(frame: CGRect.zero)
        self.drawingView.delegate = self
        self.drawingView.alwaysBounceVertical = true
        self.drawingView.drawingPolicy = .anyInput
        self.drawingView.backgroundColor = .clear
        self.drawingView.isUserInteractionEnabled = false
        self.view.addSubview(drawingView)
        self.drawingView.transform = CGAffineTransform(scaleX: Device.ratio, y: Device.ratioHeight)
        self.drawingView.widthAnchor.constraint(equalToConstant: Device.base).isActive = true
        self.drawingView.heightAnchor.constraint(equalToConstant: Device.baseHeight).isActive = true
        self.drawingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.drawingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
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
            self.view.addSubview(makeOFVTextView(textViewData: $0))
            
        }
        
        //이미지
        currentQuestion?.imageViewDatas.forEach{
            self.view.addSubview(makeOFVImageView(imageViewData: $0))
        }
        
    }
    
    func makeOFVTextView(textViewData: TextViewData) -> OFV_TextView {
        let textView = OFV_TextView(frame: CGRect(x: self.view.center.x-self.view.bounds.width/2, y: self.view.center.y-50, width: self.view.bounds.width, height: 100), textContainer: nil, textViewData: textViewData)
        
        
        
        return textView
        
        
    }
    
    func makeOFVImageView(imageViewData: ImageViewData) -> OFV_ImageView {
        let imageView = OFV_ImageView(
            frame: CGRect(x: self.view.center.x-50, y: self.view.center.y-50, width: 100, height: 100),
            imageViewData: imageViewData)
        
        return imageView
        
        
    }
}
