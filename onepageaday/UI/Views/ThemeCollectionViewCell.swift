//
//  ThemeCollectionViewCell.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/31.
//

import UIKit
import Firebase
import Gemini

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

//socialCollection
class ThemeCollectionViewCell: GeminiCell,UIContextMenuInteractionDelegate {
    
    var renderer: UIGraphicsImageRenderer?
    var image: UIImage?
    
    var id: String?
    
    weak var parentDelegate: NewsFeedViewControllerDelegate?
    
    var ofv_mainView: OFV_MainView?
    var dateLabel = UILabel().then{
        $0.font = .cafe(size: 14)
    }
    var customShadowView: UIView!
    override var shadowView: UIView? {
        return customShadowView
    }
    
    override func awakeFromNib() {
        customShadowView = .init()
        customShadowView.backgroundColor = .black
        self.addSubview(customShadowView)
        customShadowView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        ofv_mainView?.removeFromSuperview()
        ofv_mainView = nil
    }
    
    deinit {
        print("deinit ThemeCollectionViewCell")
    }
    
    public func configure(ofv_mainView: OFV_MainView?) {
        let date = DateFormatter()
        date.dateFormat = "yyyy.M.d."
        
        self.dateLabel.removeFromSuperview()
        self.addSubview(dateLabel)
        
        guard let color = UIColor(ofv_mainView?.currentQuestion?.backGroundColor ?? defaultColor) else {return}
        if color.isLight() ?? true {
            self.dateLabel.textColor = .black
        } else {
            self.dateLabel.textColor = .white
        }
        self.dateLabel.text = date.string(from: ofv_mainView?.currentQuestion?.modifiedDate ?? Date())
        
        self.dateLabel.snp.makeConstraints{
            $0.left.bottom.equalToSuperview().inset(16)
        }
        
        if let view = ofv_mainView {
            sendSubviewToBack(view)
        }

    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil) {
            self.renderer = UIGraphicsImageRenderer(size: self.bounds.size)
            self.image = self.renderer?.image { [weak self] ctx in
                if let b = self?.bounds {
                    self?.drawHierarchy(in: b, afterScreenUpdates: true)
                }
            }
            guard let img = self.image else {return nil}
                return ImagePreviewController(image: img)
            } actionProvider: { [weak self] _ in
                return self?.createContextMenu()
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
