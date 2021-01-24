//
//  ThemeCollectionViewCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/31.
//

import UIKit
import Firebase

class ImagePreviewController: UIViewController {
    private let imageView = UIImageView()
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        preferredContentSize = CGSize(width: image.size.width * 1.75, height: image.size.height * 1.75)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = image
        view = imageView
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class ThemeCollectionViewCell: UICollectionViewCell,UIContextMenuInteractionDelegate {
    
    var renderer: UIGraphicsImageRenderer?
    var image: UIImage?
    
    var id: String?
    
    var parentDelegate: ThemeIndexViewControllerDelegate?
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //trigger user interactoin
        UINotificationFeedbackGenerator().notificationOccurred(.success)

    }
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil) {
            self.renderer = UIGraphicsImageRenderer(size: self.bounds.size)
            self.image = self.renderer?.image { ctx in
                self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
            }
            guard let img = self.image else {return nil}
                return ImagePreviewController(image: img)
            } actionProvider: { _ in
                return self.createContextMenu()
            }
    }
    func createContextMenu() -> UIMenu {
        
        let saveToPhotos = UIAction(title: "사진첩에 저장", image: UIImage(systemName: "photo")) { [weak self]_ in
            print("Save to Photos")
            if let img = self?.image {
                self?.parentDelegate?.save(uiimage: img)
            }

        }
        let report = UIAction(title: "신고", image: UIImage(systemName: "bell")) { [weak self] _ in
            print("report")
            guard let questionId = self?.id else {return}
            self?.parentDelegate?.report(questionId: questionId)
            
        }
        return UIMenu(title: "", children: [saveToPhotos, report])
    }
    
   
}
