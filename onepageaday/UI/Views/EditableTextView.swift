//
//  EditableTextField.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/09.
//

import UIKit

class EditableTextView: UITextView {
    
    private weak var weakParentView: UIView?
    private weak var parentDelegate: MainViewControllerDelegate?
    
    public var textViewData: TextViewData = TextViewData(center: CGPoint.zero, angle: 0, scale: 1, text: "")
    
    //편집/되돌아가기용 캐시
    var cacheTextViewData: TextViewData = TextViewData(center: CGPoint.zero, angle: 0, scale: 1, text: "")
    var toolbar: UIToolbar!
    
    ///with textview Data
    init(frame: CGRect, textContainer: NSTextContainer?, parentView: UIView, parentDelegate: MainViewControllerDelegate, textViewData: TextViewData) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.layer.allowsEdgeAntialiasing = true // iOS7 and above.
        self.isScrollEnabled = false
        
        self.parentDelegate = parentDelegate
        self.weakParentView = parentView
        updateTextViewTransform()
        
        addGestures()
        
        //UI..
//        print(parentView.backgroundColor?.toHexString())
//        if (parentView.backgroundColor?.isLight() ?? true) {
//            self.textColor = .black
//        } else {
//            self.textColor = .white
//        }
        
        self.backgroundColor = .clear
        self.font = Constant.Design.textViewFont
        //End..
        
        self.textViewData = textViewData
        self.center = CGPoint(x: textViewData.center.x.adjusted, y: textViewData.center.y.adjustedHeight)
        self.transform = self.transform.scaledBy(x: textViewData.scale.adjusted, y: textViewData.scale.adjusted).rotated(by: textViewData.angle)
        
        
        
        //textview Input악세서리
        toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        //appearance 변경해야 해서 메모리에 저장
        toolbar.items = [
            UIBarButtonItem(image: UIImage(systemName: "text.alignleft"), style: .plain, target: self, action: #selector(align)),
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),

            ]
        
        Constant.Design.textColors.forEach {
            let item = UIBarButtonItem(image: UIImage(systemName: "circle.fill"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(color(_:)))
            item.tintColor = UIColor($0)
            toolbar.items?.append(item)
        }
        
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar

        //TextAlignment ( 변수 사용할 게 많아서 마지막에 호출 )
        setAlignment()
        setColor()
        self.layoutIfNeeded()
        
        self.text = textViewData.text

    }
    @objc func color(_ sender: UIBarButtonItem) {
        print(sender.tintColor)
        self.textViewData.textColor = sender.tintColor?.toHexString() ?? "000000"
        setColor()
    }
    @objc func align() {
        if self.textViewData.alignment == .left {
            self.textViewData.alignment = .middle
        } else if self.textViewData.alignment == .middle {
            self.textViewData.alignment = .right
        } else {
            self.textViewData.alignment = .left
        }
        setAlignment()
        self.parentDelegate?.textViewUpdated(textViewData: self.textViewData)

    }
    
    func setColor() {
        self.textColor = UIColor(textViewData.textColor)
    }
    
    func setAlignment() {
        self.textAlignment = NSTextAlignment.init(rawValue: textViewData.alignment.rawValue) ?? .center
        if self.textViewData.alignment == .left {
            self.toolbar.items?[0].image = UIImage(systemName: "text.alignleft")
        } else if self.textViewData.alignment == .middle {
            self.toolbar.items?[0].image = UIImage(systemName: "text.aligncenter")
        } else {
            self.toolbar.items?[0].image = UIImage(systemName: "text.alignright")
        }
        
    }
    
    func addGestures() {
        //add pan gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gestureRecognizer.delegate = self
        self.addGestureRecognizer(gestureRecognizer)

        //Enable multiple touch and user interaction for textfield
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = true

        //add pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)

        //add rotate gesture.
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        self.addGestureRecognizer(rotate)
        self.delegate = self
    }
    
    
    func scale(from transform: CGAffineTransform) -> CGFloat {
        return CGFloat(sqrt(Double(transform.a * transform.a + transform.c * transform.c)))
    }
    
    func updateTextViewTransform() {
        self.textViewData.center = CGPoint(x: self.center.x.reverseAdjusted, y: self.center.y.reverseAdjustedHeight)
        self.textViewData.angle = atan2(self.transform.b, self.transform.a)
        self.textViewData.scale = scale(from: self.transform).reverseAdjusted
    }
    
    func updateTextViewString() {
        self.textViewData.text = self.text ?? ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
//    //margin touch
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = self.bounds.insetBy(dx: 0, dy: 0)
        
        if parentDelegate!.getIsDrawing() || !parentDelegate!.getIsEditingMode() || self.isFocused {
            return nil
        }
        
        return frame.contains(point) ? self : nil;
    }
}


//objc funcs
extension EditableTextView: UIGestureRecognizerDelegate {
    
    //드래그앤드롭
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.weakParentView?.bringSubviewToFront(self)
            self.parentDelegate?.dragBegin()
        }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed && !isEditingSomething(){

            let translation = gestureRecognizer.translation(in: weakParentView)
            // note: 'view' is optional and need to be unwrapped
            let newPoint = CGPoint(x: gestureRecognizer.view!.center.x+translation.x, y: gestureRecognizer.view!.center.y+translation.y)
            gestureRecognizer.view!.center = newPoint
            gestureRecognizer.setTranslation(CGPoint.zero, in: weakParentView)
            
        }
        
        if gestureRecognizer.state == .ended {
            self.parentDelegate?.dragEnd(textView: self, touchPos: gestureRecognizer.location(in: weakParentView))
            updateTextViewTransform()
            self.parentDelegate?.textViewUpdated(textViewData: self.textViewData)
        }
        


    }

    //확대
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {

        if let view = pinch.view {
            
            if pinch.state == .changed {
                let pinchCenter = CGPoint(x: pinch.location(in: view).x - view.bounds.midX,
                                          y: pinch.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                                                .scaledBy(x: pinch.scale, y: pinch.scale)
                                                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                view.transform = transform
                pinch.scale = 1
            }
            
            if pinch.state == .ended {
                updateTextViewTransform()
                self.parentDelegate?.textViewUpdated(textViewData: self.textViewData)
            }
            
        }
        
        

    }
    
    //돌리기
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view{
            if !isEditingSomething() {
                view.transform = view.transform.rotated(by: recognizer.rotation)
                recognizer.rotation = 0
            }
            if recognizer.state == .ended {
                updateTextViewTransform()
                self.parentDelegate?.textViewUpdated(textViewData: self.textViewData)
            }
        }

    }
    
    //MARK:- UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
}

//textview funcs
extension EditableTextView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //그림그리기 Or 다른 텍스트 편집중일경우 return false
        return !isEditingSomething()
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        parentDelegate?.textViewEditingBegin(textView: self)
        
        cacheTextViewData.center = self.center
        cacheTextViewData.angle = atan2(self.transform.b, self.transform.a)
        cacheTextViewData.scale = scale(from: self.transform)

        UIView.animate(withDuration: 0.3) {
            if let parentView = self.weakParentView {
                self.transform = CGAffineTransform(scaleX: 1, y: 1).rotated(by: 0)
                self.center = CGPoint(x: parentView.center.x, y: parentView.center.y-(parentView.bounds.height/5.5))
                
            }
            
        }
        
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        self.updateTextViewString()
        if let parentView = self.weakParentView {
            self.center = CGPoint(x: parentView.center.x, y: parentView.center.y-(parentView.bounds.height/5.5))
            
        }
        
        let fixedWidth = weakParentView?.frame.size.width ?? textView.frame.size.width
                let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
                textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        UIView.animate(withDuration: 0.3) {
            self.center = self.cacheTextViewData.center
            
            self.transform = self.transform.scaledBy(x: self.cacheTextViewData.scale, y: self.cacheTextViewData.scale).rotated(by: self.cacheTextViewData.angle)
        } completion: { (completion) in
            self.updateTextViewTransform()
            self.parentDelegate?.textViewUpdated(textViewData: self.textViewData)

        }

        parentDelegate?.textViewEditingEnd()

        if (self.textViewData.text.isEmpty) {
            self.parentDelegate?.removeTextView(textViewData: self.textViewData)
            self.removeFromSuperview()
            
        }
        
        


    }
    
    func textViewFitWidthAndHeight() {
//        let fixedHeight = self.frame.size.height
//        let newSize = self.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: fixedHeight))
//        self.frame.size = CGSize(width: newSize.width, height: newSize.height)
        
        
        
    }
    
}

//real extension
extension EditableTextView {
    func isEditingSomething()->Bool {
        return parentDelegate!.getIsDrawing() || parentDelegate!.getIsEditingTextView()
    }
}
