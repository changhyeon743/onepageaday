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
    
    ///with textview Data
    init(frame: CGRect, textContainer: NSTextContainer?, parentView: UIView, parentDelegate: MainViewControllerDelegate, textViewData: TextViewData) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.layer.allowsEdgeAntialiasing = true // iOS7 and above.
        self.isScrollEnabled = false
        
        self.parentDelegate = parentDelegate
        self.weakParentView = parentView
        updateTextViewTransform()
        
        addGestures()
        
        self.textViewData = textViewData
        self.text = textViewData.text
        self.center = textViewData.center
        self.transform = self.transform.scaledBy(x: textViewData.scale, y: textViewData.scale).rotated(by: textViewData.angle)
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
        self.textViewData.center = self.center
        self.textViewData.angle = atan2(self.transform.b, self.transform.a)
        self.textViewData.scale = scale(from: self.transform)
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
            self.parentDelegate?.dragBegin()
        }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed && !isEditingSomething(){

            let translation = gestureRecognizer.translation(in: weakParentView)
            // note: 'view' is optional and need to be unwrapped
            let newPoint = CGPoint(x: gestureRecognizer.view!.center.x+translation.x, y: gestureRecognizer.view!.center.y+translation.y)
            gestureRecognizer.view!.center = newPoint
            gestureRecognizer.setTranslation(CGPoint.zero, in: weakParentView)
            self.weakParentView?.bringSubviewToFront(self)

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
