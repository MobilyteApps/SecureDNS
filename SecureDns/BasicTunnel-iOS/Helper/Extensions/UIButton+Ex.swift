//
//  UIButton+Ex.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 15/07/20.
//  Copyright © 2020 Davide De Rosa. All rights reserved.
//

import UIKit

public extension UIButton{
    
    subscript(title state:UIControl.State)->String?{
        set{
            self.setTitle(newValue, for: state)
        }
        get{
            return self.title(for: state)
        }
        
    }
    subscript(image state:UIControl.State)->UIImage?{
        set{
            self.setImage(newValue, for: state)
        }
        get{
            return self.image(for: state)
        }
        
    }
    subscript(backgroundImage state:UIControl.State)->UIImage?{
        set{
            self.setBackgroundImage(newValue, for: state)
        }
        get{
            return self.backgroundImage(for: state)
        }
        
    }
    
}
extension UIControl {
    
    /// Typealias for UIControl closure.
    public typealias UIControlTargetClosure = (UIControl) -> ()
    
    private class UIControlClosureWrapper: NSObject {
        let closure: UIControlTargetClosure
        init(_ closure: @escaping UIControlTargetClosure) {
            self.closure = closure
        }
    }
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIControlTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? UIControlClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, UIControlClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    public func addAction(for event: UIControl.Event, closure: @escaping UIControlTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIControl.closureAction), for: event)
    }
    
}
extension UISwitch {
    func set(width: CGFloat, height: CGFloat) {
        
        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51
        
        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth
        
        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }

    
   
}
