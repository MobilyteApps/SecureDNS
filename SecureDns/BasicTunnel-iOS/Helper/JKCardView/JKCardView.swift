//
//  JKCardView.swift
// JKMaterialKit
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
public class JKCardView: UIView {
    /// Whether to display the shadow, defaults to false.
    @IBInspectable dynamic public var isShadow: Bool = false{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    /// The color of the drop-shadow, defaults to black.
    @IBInspectable dynamic public var shadowColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /// The opacity of the drop-shadow, defaults to 0.5.
    @IBInspectable dynamic public var shadowOpacity: Float = 0.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    /// The x,y offset of the drop-shadow from being cast straight down.
    @IBInspectable dynamic public var shadowOffset: CGSize = CGSize(width:0,height:3) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /// The blur radius of the drop-shadow, defaults to 3.
    @IBInspectable dynamic public var shadowRadius : CGFloat = 3.0 {
        didSet{
            self.setNeedsDisplay()
        }
    }
    /// The blur radius of the shadowPath cornerRadius, defaults to 3.
    @IBInspectable dynamic public var shadowCornerRadius : CGFloat = 3.0{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable dynamic public var cornerRadius: CGFloat = 2.5 {
        didSet {
            self.setNeedsDisplay()
        }
    }
   
    
    @IBInspectable dynamic public var borderColor: UIColor =  UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            self.setNeedsDisplay()
            
        }
    }
    @IBInspectable dynamic public var borderWidth: CGFloat =  0 {
        didSet {
            layer.borderWidth = borderWidth
            self.setNeedsDisplay()
            
        }
    }
    @IBInspectable dynamic public var masksToBounds : Bool = false{
        didSet{
            layer.masksToBounds = isShadow ? false : masksToBounds
            self.setNeedsDisplay()
        }
        
    }
    @IBInspectable dynamic public var clipsToBound : Bool = false{
        didSet{
            self.clipsToBounds = clipsToBound
            self.setNeedsDisplay()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if isShadow == true{
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: shadowCornerRadius)
            layer.shadowPath = shadowPath.cgPath
           
        }else{
            // Disable the shadow.
            layer.shadowRadius = 0
            layer.shadowOpacity = 0
            layer.shadowPath = nil
        }
        layer.cornerRadius = cornerRadius
        self.setNeedsDisplay()
        
    }
    
}

/// Clear the child views.
public  extension UIView {
    
    func clearChildViews(){
        subviews.forEach({ $0.removeFromSuperview() })
    }
   
}
