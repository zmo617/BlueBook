//
//  RoundBtn.swift
//  draft1
//
//  Created by Claire Mo on 6/18/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
@IBDesignable
class RoundBtn: UIButton {
    
    @IBInspectable var cornerRadius : CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
