//
//  EditableTextField.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/09.
//

import UIKit
import Kingfisher

class EditableImageView: AnimatedImageView {
    
    private weak var weakParentView: UIView?
    private weak var parentDelegate: MainViewControllerDelegate?
    
    public var imageViewData: ImageViewData = ImageViewData(center: CGPoint.zero, angle: 0, scale: 1, imageURL: "")
    
    init(frame: CGRect, parentView: UIView, parentDelegate: MainViewControllerDelegate, imageViewData: ImageViewData) {
        super.init(frame: frame)
        self.layer.allowsEdgeAntialiasing = true // iOS7 and above.
        
        self.parentDelegate = parentDelegate
        self.weakParentView = parentView
        
        self.imageViewData = imageViewData
        //ADJUSTED!!
        self.center = CGPoint(x: imageViewData.center.x.adjusted, y: imageViewData.center.y.adjustedHeight)
        
        self.transform = self.transform.scaledBy(x: imageViewData.scale.adjusted, y: imageViewData.scale.adjusted).rotated(by: imageViewData.angle)
        
        if let url = URL(string: imageViewData.imageURL) {
            self.kf.indicatorType = .activity
            self.kf.setImage(with: url, options: [.transition(ImageTransition.fade(0.5))])
        }
        
        
        
        addGestures()
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
        
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapRecognized(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    
    func scale(from transform: CGAffineTransform) -> CGFloat {
        return CGFloat(sqrt(Double(transform.a * transform.a + transform.c * transform.c)))
    }
    
    func updateImageViewTransform() {
        self.imageViewData.center = CGPoint(x: self.center.x.reverseAdjusted, y: self.center.y.reverseAdjustedHeight)
        self.imageViewData.angle = atan2(self.transform.b, self.transform.a)
        self.imageViewData.scale = scale(from: self.transform).reverseAdjusted
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
//    //margin touch
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let frame = self.bounds.insetBy(dx: 0, dy: 0)
        
        if parentDelegate!.getIsDrawing() || !parentDelegate!.getIsEditingMode() {
            return nil
        }
        
        return frame.contains(point) ? self : nil;
    }
}


//objc funcs
extension EditableImageView: UIGestureRecognizerDelegate {
    
    
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
            self.parentDelegate?.dragEnd(imageView: self, touchPos: gestureRecognizer.location(in: weakParentView))

            updateImageViewTransform()
            self.parentDelegate?.imageViewUpdated(imageViewData: self.imageViewData)
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
                updateImageViewTransform()
                self.parentDelegate?.imageViewUpdated(imageViewData: imageViewData)
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
                updateImageViewTransform()
                self.parentDelegate?.imageViewUpdated(imageViewData: imageViewData)
            }
        }

    }
    
    @objc func tapRecognized(_ recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            updateImageViewTransform()
            self.parentDelegate?.imageViewUpdated(imageViewData: imageViewData)

        }

    }
    
    //MARK:- UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
}


//real extension
extension EditableImageView {
    func isEditingSomething()->Bool {
        return parentDelegate!.getIsDrawing() || parentDelegate!.getIsEditingTextView()
    }
}
