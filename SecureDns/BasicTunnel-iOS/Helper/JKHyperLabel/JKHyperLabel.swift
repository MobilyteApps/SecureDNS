//
//  JKHyperLabel.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 18/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
extension UIView {
    private struct OnClickHolder {
        static var _closure:(_ gesture: UITapGestureRecognizer)->() = {_ in }
    }
    
    private var onClickClosure: (_ gesture: UITapGestureRecognizer) -> () {
        get { return OnClickHolder._closure }
        set { OnClickHolder._closure = newValue }
    }
    
    
    func onClick(target: Any, _ selector: Selector) {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: selector)
        addGestureRecognizer(tap)
    }
    func onClick(closure: @escaping (_ gesture: UITapGestureRecognizer)->()) {
        self.onClickClosure = closure
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(onClickAction))
        addGestureRecognizer(tap)
    }
    
    @objc private func onClickAction(_ gesture: UITapGestureRecognizer) {
        onClickClosure(gesture)
    }
    
}
extension NSMutableAttributedString {
    func removeAttributes() {
        let range = NSMakeRange(0, self.length)
        self.removeAttributes(range: range)
    }
    
    func removeAttributes(range: NSRange) {
        self.enumerateAttributes(in: range, options: []) { (attributes, range, _) in
            for attribute in attributes {
                self.removeAttribute(attribute.key, range: range)
            }
        }
    }
}
extension UILabel{
    
    func setLinkFor(_ subStrings:String...,linkAttributed:[NSAttributedString.Key:Any]?  = nil,completion:@escaping(UILabel, String)->Void){
        let font = UIFont.systemFont(ofSize: self.font!.pointSize, weight: .semibold)
        let underlineColor:UIColor = self.textColor
        if let attributedText = self.attributedText {
            let attributedString = NSMutableAttributedString(attributedString: attributedText)
            
            for string in subStrings {
                let linkRange = (attributedText.string as NSString).range(of: string)
                let linkAttributedDict:[NSAttributedString.Key:Any] = linkAttributed == nil ? [.underlineColor: underlineColor,.underlineStyle:NSUnderlineStyle.single.rawValue,.strokeColor: self.textColor!,.font:font] : linkAttributed!
                attributedString.addAttributes(linkAttributedDict, range: linkRange)
            }
            
            self.attributedText = attributedString
            
        }else if let text  = self.text{
            
            let fullRange  = NSMakeRange(0, text.count)
            let attributedString = NSMutableAttributedString(string: text)
            let textAttributed:[NSAttributedString.Key:Any] = [.font: self.font!,.foregroundColor: self.textColor!]
            attributedString.addAttributes(textAttributed, range: fullRange)
            for string in subStrings {
                let linkRange = (text as NSString).range(of: string)
                let linkAttributedDict:[NSAttributedString.Key:Any] = linkAttributed == nil ? [.underlineColor: underlineColor,.underlineStyle:NSUnderlineStyle.single.rawValue,.strokeColor: self.textColor!,.font: font] : linkAttributed!
                attributedString.addAttributes(linkAttributedDict, range: linkRange)
            }
            
            self.attributedText = attributedString
        }
        self.onClick {gesture in
            guard let text = self.text else { return }
            for string in subStrings {
                let rRange = ( text as NSString).range(of: string)
                if gesture.didTapAttributedTextInLabel(label: self, inRange: rRange) {
                    
                    completion(self,string)
                }
            }
            
        }
        
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        var indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        indexOfCharacter = indexOfCharacter + 4
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


