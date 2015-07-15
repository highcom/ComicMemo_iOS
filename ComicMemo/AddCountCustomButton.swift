//
//  AddCountCustomButton.swift
//  ComicMemo
//
//  Created by 晃一 on 2015/07/15.
//  Copyright (c) 2015年 晃一. All rights reserved.
//

import UIKit

@IBDesignable
class AddCountCustomButton: UIButton {
    @IBInspectable var textColor: UIColor?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
}
