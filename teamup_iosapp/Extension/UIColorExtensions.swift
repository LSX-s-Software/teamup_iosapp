//
//  UIColorExtensions.swift
//  teamup_iosapp
//
//  Created by 林思行 on 2022/9/9.
//

import UIKit

extension UIColor {

    // MARK: - UIColor to hex
    func toHex(withAlpha alpha: Bool = false) -> String? {
        guard let components = cgColor.components else {
            return nil
        }
        
        let r: Float, g: Float, b: Float, a: Float
        if components.count == 2 {
            r = Float(components[0])
            g = r
            b = r
            a = Float(components[1])
        } else {
            r = Float(components[0])
            g = Float(components[1])
            b = Float(components[2])
            a = components.count >= 4 ? Float(components[3]) : Float(1.0)
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }

}
