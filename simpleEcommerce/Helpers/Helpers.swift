//
//  Helpers.swift
//  simpleEcommerce
//
//  Created by Abdullah Onur Şimşek on 29.12.2021.
//
//
import Foundation
import UIKit

//MARK: - Extensions For Navigation Item Badge
extension CAShapeLayer {
func drawRoundedRect(rect: CGRect, andColor color: UIColor, filled: Bool) {
    fillColor = filled ? color.cgColor : UIColor.white.cgColor
    strokeColor = color.cgColor
    path = UIBezierPath(roundedRect: rect, cornerRadius: 7).cgPath
}
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
private var badgeLayer: CAShapeLayer? {
    if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
        return b as? CAShapeLayer
    } else {
        return nil
    }
}

func setBadge(text: String?, withOffsetFromTopRight offset: CGPoint = CGPoint.zero, andColor color:UIColor = UIColor.white, andFilled filled: Bool = true, andFontSize fontSize: CGFloat = 11)
{
    badgeLayer?.removeFromSuperlayer()

    if (text == nil || text == "" || text == "0") {
        return
    }

    addBadge(text: text!, withOffset: offset, andColor: color, andFilled: filled)
}

private func addBadge(text: String, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.white, andFilled filled: Bool = true, andFontSize fontSize: CGFloat = 11)
{
    guard let view = self.customView else { return }

    var font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)

    font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
    
    let badgeSize = text.size(withAttributes: [NSAttributedString.Key.font: font])

    // Initialize Badge
    let badge = CAShapeLayer()

    let height = badgeSize.height;
    var width = badgeSize.width + 2 /* padding */

    //make sure we have at least a circle
    if (width < height) {
        width = height
    }

    //x position is offset from right-hand side
    let x = view.frame.width - width + offset.x + 2

    let badgeFrame = CGRect(origin: CGPoint(x: x, y: offset.y-3), size: CGSize(width: width, height: height))

    badge.drawRoundedRect(rect: badgeFrame, andColor: color, filled: filled)
    badge.shadowColor = UIColor.gray.cgColor
    badge.shadowOffset = CGSize(width: 0, height: 5)
    badge.shadowRadius = 5
    badge.shadowOpacity = 0.8
    view.layer.addSublayer(badge)

    // Initialiaze Badge's label
    let label = CATextLayer()
    label.string = text
    label.alignmentMode = CATextLayerAlignmentMode.center
    label.font = font
    label.fontSize = font.pointSize

    label.frame = badgeFrame
    label.foregroundColor = filled ? UIColor.black.cgColor : color.cgColor
    label.backgroundColor = UIColor.clear.cgColor
    label.contentsScale = UIScreen.main.scale
    badge.addSublayer(label)

    // Save Badge as UIBarButtonItem property
    objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
}

private func removeBadge() {
    badgeLayer?.removeFromSuperlayer()
}
}

//MARK: - Extension For UIColoe HexString

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

//MARK: - Extension For Colors in App

extension UIColor {
    @nonobjc class var  appMainBlue: UIColor {
        return UIColor(hexString:"#1C6DD0")
    }
    @nonobjc class var  appMainGray: UIColor {
        return UIColor(hexString:"#E8EAE6")
    }
    @nonobjc class var  appBorderGray: UIColor {
        return UIColor(hexString:"#CDD0CB")
    }
    @nonobjc class var appLightBlue: UIColor {
        return UIColor(hexString: "#A3E4DB")
    }
    @nonobjc class var appTextGray: UIColor {
        return UIColor(hexString: "#AAAAAA")
    }
}

extension UIView {
    func makeShadow() {
        self.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
    }
}

//MARK: - Strings

extension Notification.Name {
    static let cartCountChanged = Notification.Name.init(rawValue: "cartCountChanged")
}


