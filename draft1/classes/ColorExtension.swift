//
//  ColorExtension.swift
//  draft1
//
//  Created by Claire Mo on 7/2/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    //appBlue:2081AF
    static let appBlue = UIColor().colorFromHex("2081AF")
  
    func colorFromHex(_ hex: String) -> UIColor{
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#"){
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6{
            return UIColor.black
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: 1.0)
    }
}
