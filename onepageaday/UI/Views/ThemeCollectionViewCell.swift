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
    var nativeAdView: GADNativeAdView?
    
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
        
        nativeAdView?.removeFromSuperview()
        nativeAdView = nil
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
    
    public func configure(nativeAd: GADNativeAd) {
        nativeAdView = UINib(nibName: "UnifiedNativeAdView", bundle: nil).instantiate(withOwner: self, options: nil).first as? GADNativeAdView
        self.backgroundColor = nativeAdView!.backgroundColor
        self.addSubview(nativeAdView!)
        nativeAdView!.snp.makeConstraints{
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(48)
        }
        
        (nativeAdView!.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView!.mediaView?.mediaContent = nativeAd.mediaContent

        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
          mediaContent.videoController.delegate = self
        }

        (nativeAdView!.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView!.bodyView?.isHidden = nativeAd.body == nil

        (nativeAdView!.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView!.callToActionView?.isHidden = nativeAd.callToAction == nil

        (nativeAdView!.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView!.iconView?.isHidden = nativeAd.icon == nil

        (nativeAdView!.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView!.storeView?.isHidden = nativeAd.store == nil

        (nativeAdView!.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView!.priceView?.isHidden = nativeAd.price == nil

        (nativeAdView!.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView!.advertiserView?.isHidden = nativeAd.advertiser == nil

        nativeAdView!.callToActionView?.isUserInteractionEnabled = false

        nativeAdView!.nativeAd = nativeAd
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

extension ThemeCollectionViewCell: GADVideoControllerDelegate {
    
}
