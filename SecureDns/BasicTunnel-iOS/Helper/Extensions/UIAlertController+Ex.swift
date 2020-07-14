//
//  UIAlertController+Ex.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

typealias UIAlertActionHandler = (_ controller:UIAlertController, _ action:UIAlertAction, _ buttonIndex:Int)->Void
enum AlertActionIndex:Int {
    case cancel = 0
    case destructive = 1
    case firstOther = 2
    var index:Int{
        self.rawValue
    }
}

struct AlertFields {
    var placeholder:String = ""
    var isSecureTextEntry:Bool = false
    var borderStyle:UITextField.BorderStyle = .none
    init(placeholder:String,isSecure:Bool = false,borderStyle:UITextField.BorderStyle = .none) {
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        self.borderStyle = borderStyle
    }
    
}




struct AlertControllerModel {
    var alertContentController:AlertContentController? = nil
    var title:String?
    var message:String?
    var titleFont:UIFont? = nil
    var messageFont:UIFont? = nil
    var titleColor:UIColor? = nil
    var messageColor:UIColor? = nil
    var tintColor:UIColor? = nil
    init(contentViewController controller: AlertContentController? = nil, title: String?  = nil, message: String?  = nil, titleFont: UIFont? = nil, messageFont: UIFont? = nil, titleColor: UIColor? = nil, messageColor: UIColor? = nil, tintColor: UIColor? = nil){
        self.alertContentController = controller
        self.title = title
        self.message = message
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.tintColor = tintColor
        
    }
    
}
struct AlertContentController {
    var viewController:UIViewController? = nil
    var height:CGFloat? = nil
    
    init(controller:UIViewController? = nil, height:CGFloat? = nil) {
        viewController = controller
        self.height = height
    }
}
struct AlertActionModel {
    
    var title: Title!
    var style: UIAlertAction.Style = .cancel
    var alignmentMode:CATextLayerAlignmentMode?
    init(actionTitle title:Title = Title(title: "Cancel") , style:UIAlertAction.Style = .cancel,alignmentMode mode:CATextLayerAlignmentMode? = nil) {
        
        self.title = title
        self.style = style
        alignmentMode = mode
    }
    
    
    struct Title {
        var title: String = "Cancel"
        var color: UIColor? = nil
        init(title :String = "Cancel", titleColor color:UIColor? = nil) {
            self.title = title
            self.color = color
        }
        
    }
}

extension UIAlertController{
    
    fileprivate struct ActionCustomKey{
        static let imageKey = "image"
        static let titleTextColorKey = "titleTextColor"
        static let attributedTitleKey = "attributedTitle"
        static let titleTextAlignmentKey = "titleTextAlignment"
        static let attributedMessageKey = "attributedMessage"
        static let contentViewControllerKey = "contentViewController"
    }
    
    fileprivate var cancelButtonIndex        :Int        { return AlertActionIndex.cancel.index       }
    fileprivate var firstOtherButtonIndex    :Int        { return AlertActionIndex.firstOther.index   }
    fileprivate var destructiveButtonIndex   :Int        { return AlertActionIndex.destructive.index  }
    fileprivate var addTextFieldIndex        :Int        { return 0   }
    
    //MARK: - convenience init
    convenience init(model:AlertControllerModel, preferredStyle:UIAlertController.Style = .alert, source: Any? = nil) {
        self.init(title: model.title, message: model.message, preferredStyle: preferredStyle, source: source, tintColor: model.tintColor)
        
        if let controller = model.alertContentController {
            self.set(vc: controller.viewController,height: controller.height)
        }
        if let title  = model.title, let font = model.titleFont , let color  = model.titleColor{
            self.set(title: title, font: font, color: color)
        }
        if let message  = model.message, let font = model.messageFont , let color  = model.messageColor{
            self.set(message: message, font: font, color: color)
        }
    }
    convenience init(title:String?  = nil, message:String?  = nil , preferredStyle:UIAlertController.Style = .alert, source: Any? = nil, tintColor:UIColor?){
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        
        // TODO: for iPad or other views
        #if os(iOS)
        if preferredStyle == .actionSheet, let source = source {
            
            if let barButtonItem = source as? UIBarButtonItem {
                
                if let popoverController = self.popoverPresentationController {
                    popoverController.barButtonItem = barButtonItem
                    
                }
                
            }else if let source = source as? UIView{
                if let popoverController = self.popoverPresentationController {
                    popoverController.sourceView = source
                    popoverController.sourceRect = source.bounds
                }
                
            }
        }
        #endif
        if let tintColor = tintColor {
            self.view.tintColor = tintColor
        }
        
    }
    
    //MARK: - presentAlert
    fileprivate func present(from viewController:UIViewController = rootController!, completion: (() -> Swift.Void)? = nil){
        DispatchQueue.main.async {
            viewController.present(self, animated: true, completion: completion)
        }
    }
    
    
    
    
    //MARK: - otherAlertAction
    fileprivate func otherAction(others:[AlertActionModel],handler:@escaping UIAlertActionHandler){
        for (index,obj) in others.enumerated() {
            addAction(action:obj, handler: { (action:UIAlertAction) in
                handler(self,action,self.firstOtherButtonIndex+index)
            })
            
        }
        
    }
    
    
    //MARK: - cancelAlertAction
    
    fileprivate func cancelAction(cancel:AlertActionModel,handler:@escaping UIAlertActionHandler){
        addAction(action:cancel, handler: { (action:UIAlertAction) in
            handler(self,action,self.cancelButtonIndex)
        })
        
    }
    //MARK: - destructiveAlertAction
    fileprivate  func destructiveAction(destructive:AlertActionModel,handler:@escaping UIAlertActionHandler){
        addAction(action: destructive, handler: { (action:UIAlertAction) in
            handler(self,action,self.destructiveButtonIndex)
        })
        
    }
    //MARK: - OtherTextField
    ///
    ///   - Parameters:
    ///     - placeholder:String (default is Empty)
    ///     - isSecureTextEntry:Bool(default is false)
    ///     - borderStyle:UITextField.BorderStyle(default is  .none)
    
    fileprivate  func addOtherTextField(placeholders: [AlertFields]){
        for (index,element) in placeholders.enumerated() {
            self.addTextField {
                $0.tag = self.addTextFieldIndex+index
                $0.placeholder = NSLocalizedString(element.placeholder, comment: "")
                $0.borderStyle = element.borderStyle
                $0.isSecureTextEntry = element.isSecureTextEntry
            }
        }
        
        
        
    }
    
    
    
    //MARK: - Add an action to Alert
    
    ///
    ///   - Parameters:
    ///     - actionIcon:UIImage? (default is nil)
    ///     - alignmentMode:CATextLayerAlignmentMode?(default is nil)
    ///     - title: AlertActionTitle(action title)
    ///     - style: action style (default is UIAlertActionStyle.default)
    ///     - isEnabled: isEnabled status for action (default is true)
    ///     - handler: optional action handler to be called when button is tapped (default is nil)
    ///
    fileprivate func addAction(action model:AlertActionModel, isEnabled: Bool = true, handler: ((UIAlertAction) -> Void)? = nil) {
        let action = UIAlertAction(title: model.title.title, style: model.style, handler: handler)
        action.isEnabled = isEnabled
        
        
        // button title color
        if let color = model.title.color {
            //titleTextColor
            action.setValue(color, forKey: ActionCustomKey.titleTextColorKey)
        }
        if let alignment = model.alignmentMode {
            action.setValue(alignment, forKey: ActionCustomKey.titleTextAlignmentKey)
        }
        
        addAction(action)
    }
    
    ///- Set alert's title, font and color
    /// - Parameters:
    ///  - title: alert title
    ///  - font: alert title font
    ///  - color: alert title color
    ///
    
    fileprivate  func set(title: String?, font: UIFont, color: UIColor) {
        if title != nil {
            self.title = title
        }
        setTitle(font: font, color: color)
    }
    
    fileprivate func setTitle(font: UIFont, color: UIColor) {
        guard let title = self.title else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: attributes)
        setValue(attributedTitle, forKey: ActionCustomKey.attributedTitleKey)
        
    }
    
    /// Set alert's message, font and color
    ///
    ///   - Parameters:
    ///    - message: alert message
    ///    - font: alert message font
    ///    - color: alert message color
    
    func set(message: String?, font: UIFont, color: UIColor) {
        if message != nil {
            self.message = message
        }
        setMessage(font: font, color: color)
    }
    
    fileprivate func setMessage(font: UIFont, color: UIColor) {
        guard let message = self.message else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: attributes)
        setValue(attributedMessage, forKey: ActionCustomKey.attributedMessageKey)
        
    }
    
    /// Set alert's content viewController
    ///
    /// - Parameters:
    ///   - vc: ViewController
    ///   - height: height of content viewController
    
    func set(vc: UIViewController?, height: CGFloat? = nil) {
        guard let vc = vc else { return }
        setValue(vc, forKey: ActionCustomKey.contentViewControllerKey)
        if let height = height {
            vc.preferredContentSize.height = height
            preferredContentSize.height = height
        }
    }
    //MARK:- addAlertAction
    /// set Actions and TextField
    ///
    /// - Parameters:
    ///   - actions:[AlertActionModel]
    ///   - otherTextFields: [AlertFields]
    func addAlertAction(actions:Any,otherTextFields placeholders:[AlertFields]? = nil,alertActionHandler:  @escaping UIAlertActionHandler) -> UIAlertController{
        
        if let list  = actions as? [AlertActionModel] {
            var others:[AlertActionModel] = [AlertActionModel]()
            for obj in list{
                if obj.style == .destructive{
                    self.destructiveAction(destructive: obj, handler: alertActionHandler)
                }else if obj.style == .cancel{
                    self.cancelAction(cancel: obj, handler: alertActionHandler)
                }else{
                    others.append(obj)
                }
            }
            
            if others.count>0{
                self.otherAction(others: others, handler: alertActionHandler)
            }
        }else if  let obj = actions as? AlertActionModel{
            if obj.style == .destructive{
                self.destructiveAction(destructive: obj, handler: alertActionHandler)
            }else if obj.style == .default{
                self.otherAction(others: [obj], handler: alertActionHandler)
            }else{
                self.cancelAction(cancel: obj, handler: alertActionHandler)
            }
        }
        
        if let placeholders  = placeholders, placeholders.count>0 {
            self.addOtherTextField(placeholders: placeholders)
        }
        
        return self
    }
    
    //MARK: - Class Functions
    ///
    ///   - Parameters:
    ///     - model:AlertControllerModel
    ///     - preferredStyle:AlertController style (default is UIAlertController.Style.alert)
    ///     - actions: alert action model list
    ///     - source: source where will be show view like UIBarButtonItem or Custom Any View(textfield, button,View etc) (default is nil)
    ///     - otherTextFields: add textField in alertView  (default is nil)
    ///     - alertActionHandler: optional action handler to be called when button is tapped (default is nil)
    ///
    
    class func alertController(model:AlertControllerModel, preferredStyle:UIAlertController.Style = .alert, source: Any? = nil,actions:Any,otherTextFields placeholders:[AlertFields]? = nil,alertActionHandler:@escaping UIAlertActionHandler) -> UIAlertController{
        var controller = UIAlertController(model: model, preferredStyle: preferredStyle, source: source)
        //        if let subview = (controller.view.subviews.first?.subviews.first?.subviews.first!){
        //            subview.backgroundColor = .bgColor
        //        }
        controller = controller.addAlertAction(actions: actions, otherTextFields: placeholders, alertActionHandler: alertActionHandler)
        return controller
    }
    
    
    class func showAlert(from viewController:UIViewController ,controlModel:AlertControllerModel, actions:Any,otherTextFields placeholders:[AlertFields]? = nil, source: Any? = nil, alertActionHandler:@escaping UIAlertActionHandler)-> UIAlertController{
        
        let alert = self.alertController(model: controlModel, preferredStyle: .alert, source: source, actions: actions, otherTextFields: placeholders, alertActionHandler: alertActionHandler)
        alert.present(from: viewController)
        return alert
        
    }
    class func showActionSheet(from viewController:UIViewController!,controlModel:AlertControllerModel, actions:Any,otherTextFields placeholders:[AlertFields]? = nil, source: Any? = nil,alertActionHandler:@escaping UIAlertActionHandler) -> UIAlertController{
        let alert = self.alertController(model: controlModel, preferredStyle: .actionSheet, source: source, actions: actions, otherTextFields: placeholders, alertActionHandler: alertActionHandler)
        alert.present(from: viewController)
        return alert
    }
    
    
}
