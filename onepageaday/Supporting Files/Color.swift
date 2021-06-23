import Foundation
import UIKit

let defaultColor = "ffffff"

//https://mobiraft.com/ios/swift/swift-recipe/convert-hex-colour-to-uicolor/
extension UIColor {
    
    convenience init?(_ string: String) {
        let hex = string.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        if #available(iOS 13, *) {
            //If your string is not a hex colour String then we are returning white color. you can change this to any default colour you want.
            guard let int = Scanner(string: hex).scanInt32(representation: .hexadecimal) else { return nil }
            
            let a, r, g, b: Int32
            switch hex.count {
            case 3:     (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)  // RGB (12-bit)
            case 6:     (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)                    // RGB (24-bit)
            case 8:     (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)       // ARGB (32-bit)
            default:    (a, r, g, b) = (255, 0, 0, 0)
            }
            
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
            
        } else {
            var int = UInt32()
            
            Scanner(string: hex).scanHexInt32(&int)
            let a, r, g, b: UInt32
            switch hex.count {
            case 3:     (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)  // RGB (12-bit)
            case 6:     (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)                    // RGB (24-bit)
            case 8:     (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)       // ARGB (32-bit)
            default:    (a, r, g, b) = (255, 0, 0, 0)
            }
            
            self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
        }
    }
    
    func toHexString() -> String {
            var r:CGFloat = 0
            var g:CGFloat = 0
            var b:CGFloat = 0
            var a:CGFloat = 0
            getRed(&r, green: &g, blue: &b, alpha: &a)
            let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
            return String(format:"%06x", rgb)
    }
    
    //https://stackoverflow.com/questions/2509443/check-if-uicolor-is-dark-or-bright
    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // Some people report that 0.7 is best. I suggest to find out for yourself.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return nil
        }
        guard components.count >= 3 else {
            return nil
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)
        return (brightness > threshold)
    }
}

