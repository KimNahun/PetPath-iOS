//
//  ColorSet.swift
//  PetPath
//
//  Created by 김나훈 on 3/1/25.
//

import UIKit.UIColor

enum ColorSet {
    // Primary Colors
    static let primary4 = UIColor.named("primary4")
    static let primary10 = UIColor.named("primary10")
    static let primary50 = UIColor.named("primary50")
    static let primary100 = UIColor.named("primary100")
    static let primary200 = UIColor.named("primary200")
    static let primary300 = UIColor.named("primary300")
    static let primary400 = UIColor.named("primary400")
    static let primary500 = UIColor.named("primary500")
    static let primary600 = UIColor.named("primary600")
    static let primary700 = UIColor.named("primary700")
    static let primary800 = UIColor.named("primary800")
    static let primary900 = UIColor.named("primary900")
    
    // Secondary Colors
    static let secondary50 = UIColor.named("secondary50")
    static let secondary100 = UIColor.named("secondary100")
    static let secondary200 = UIColor.named("secondary200")
    static let secondary300 = UIColor.named("secondary300")
    static let secondary400 = UIColor.named("secondary400")
    static let secondary500 = UIColor.named("secondary500")
    static let secondary600 = UIColor.named("secondary600")
    static let secondary700 = UIColor.named("secondary700")
    static let secondary800 = UIColor.named("secondary800")
    static let secondary900 = UIColor.named("secondary900")
    
    // Neutral Colors
    static let neutral1 = UIColor.named("neutral1")
    static let neutral2 = UIColor.named("neutral2")
    static let neutral3 = UIColor.named("neutral3")
    static let neutral4 = UIColor.named("neutral4")
    static let neutral5 = UIColor.named("neutral5")
    static let neutral6 = UIColor.named("neutral6")
    static let neutral7 = UIColor.named("neutral7")
    static let neutral8 = UIColor.named("neutral8")
    static let neutral9 = UIColor.named("neutral9")
    static let neutral10 = UIColor.named("neutral10")
    static let neutral11 = UIColor.named("neutral11")
    static let neutral12 = UIColor.named("neutral12")
    static let neutral13 = UIColor.named("neutral13")
    
    // Component Colors
    static let component1 = UIColor.named("component1")
    static let component2 = UIColor.named("component2")
    static let component3 = UIColor.named("component3")
    static let component4 = UIColor.named("component4")
    
    // Error Colors
    static let error1 = UIColor.named("error1")
    static let error2 = UIColor.named("error2")
    
    
    // Etc
    
    static let red = UIColor.named("red")
    static let tertiary = UIColor.named("tertiary")
    static let gray500 = UIColor.named("gray500")
    static let dark = UIColor.named("dark")
    static func fromHex(_ hex: String) -> UIColor {
           return UIColor.hex(hex)
       }
}

extension UIColor {
    static func named(_ name: String) -> UIColor {
        guard let color = UIColor(named: name) else {
            return .clear
        }
        return color
    }
    static func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
            
            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)
            
            let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
            let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
            let b = CGFloat(rgb & 0xFF) / 255.0
            
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
}

