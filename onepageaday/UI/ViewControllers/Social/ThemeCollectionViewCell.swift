//
//  ThemeCollectionViewCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/31.
//

import UIKit
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
        
        let shareAction = UIAction(title: "Like", image: UIImage(systemName: "heart")) { _ in
            print("Like")
        }
        let saveToPhotos = UIAction(title: "Save", image: UIImage(systemName: "photo")) { _ in
            print("Save to Photos")
        }
        let report = UIAction(title: "Report", image: UIImage(systemName: "bell")) { _ in
            print("report")
        }
        return UIMenu(title: "", children: [shareAction, saveToPhotos, report])
    }
    
}
