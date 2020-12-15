//
//  String.swift
//  onepageaday
//
//  Created by 이창현 on 2020/12/14.
//

import Foundation
import UIKit

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
    
    func emojiToUIImage() -> UIImage? {
            let size = CGSize(width: 40, height: 40)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            UIColor.white.set()
            let rect = CGRect(origin: .zero, size: size)
            UIRectFill(CGRect(origin: .zero, size: size))
            (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 40)])
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
}
