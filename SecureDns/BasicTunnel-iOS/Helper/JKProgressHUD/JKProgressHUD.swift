//
//  JKLoader.swift
// ADGAP
//
//  Created by Jitendra Kumar on 08/01/19.
//  Copyright © 2019 Jitendra Kumar. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics


let mpi :CGFloat = CGFloat(Double.pi)


//MARK:-JKProgressHUD-
public class JKProgressHUD:UIView{
    
    enum HudStyle:Int {
        case Indeterminate = 0
        case HorizontalBar
    }
    
    enum BackgroundStyle:Int {
        /// Solid color background
        case  solid = 0
        case  clear
        case  darkBlur
        
    }
    enum Position:Int {
        
        case  center = 0
        case  top
        case  bottom
        
    }
    /// - Parameters:- Only For JKIndicatorView
    
    public var islineColors:Bool = false{
        didSet{
            
            setNeedsDisplay()
        }
    }
    public var lineColors: [UIColor] = [.systemBlue,.systemGreen]{
        didSet{
            
            setNeedsDisplay()
        }
    }
    public var lineColor: UIColor = .systemBlue{
        didSet{
            
            setNeedsDisplay()
        }
    }
    public var lineWidth: CGFloat = 3{
        didSet{
            setNeedsDisplay()
        }
    }
    public var showBarline: Bool = false{
        didSet{
            
            setNeedsDisplay()
        }
    }
    public var textColor: UIColor = UIColor.darkGray{
        didSet{
            setNeedsDisplay()
        }
    }
    public var progressColor: UIColor = .systemGreen{
        didSet{
            setNeedsDisplay()
        }
    }
    public var progress: Float = 0.0{
        didSet{
            if progress >= 1.0 {
                progress = 1
            }else if progress <= 0{
                progress = 0
                
            }
            self.setProgress(value: progress)
            self.setNeedsDisplay()
            
        }
    }
    public var messageString: String = ""{
        didSet{
            
            self.setNeedsDisplay()
        }
    }
    
    var hudPosition :Position = .center
    var backgroundStyle:BackgroundStyle = .solid
    var hudMode :HudStyle = .Indeterminate
    
    fileprivate var hudContentView:JKCardView!
    fileprivate var systemBarIndicator: JKSystemProgressBar!
    fileprivate var indicatorView :JKIndicatorView!
    fileprivate var label : UILabel!
    
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    private init(hudMode mode:HudStyle = .Indeterminate,backgroundStyle style:BackgroundStyle = .solid,hudPosition position:Position = .center,titleLabel title:String = "") {
        super.init(frame: .zero)
        self.hudMode = mode
        self.hudPosition = position
        self.backgroundStyle = style
        self.messageString =   title.isEmpty ? "" : title
    }
    
    //MARK:-showProgressHud inView-
    class func showProgressHud(inView superView:UIView,progressMode mode:HudStyle = .Indeterminate,backgroundStyle style:BackgroundStyle = .solid,hudPosition position:Position = .center,titleLabel title:String = "")->JKProgressHUD{
        let hud = JKProgressHUD(hudMode: mode, backgroundStyle: style, hudPosition: position, titleLabel: title)
        superView.addSubview(hud)
        hud.updatehudContraints(item: hud, toItem: superView)
        hud.showHud()
        return hud
    }
    
    
    
    //MARK:-updatehudContraints-
    fileprivate  func updatehudContraints(item:UIView, toItem:UIView){
        item.translatesAutoresizingMaskIntoConstraints = false
        [
            item.topAnchor.constraint(equalTo: toItem.topAnchor, constant: 0),
            item.bottomAnchor.constraint(equalTo: toItem.bottomAnchor, constant: 0),
            item.leadingAnchor.constraint(equalTo: toItem.leadingAnchor, constant: 0),
            item.trailingAnchor.constraint(equalTo: toItem.trailingAnchor, constant: 0),
            ].forEach({$0.isActive = true})
        self.layoutIfNeeded()
        //self.setNeedsDisplay()
    }
    //MARK:-initilaize-
    fileprivate func initilaize(){
        self.backgroundColor = self.backgroundStyle == .clear ? UIColor.clear : UIColor(white: 0.1, alpha: 0.45)
        self.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
            self.addContentView()
        })
        
        
        
    }
    fileprivate func addBlurView(style:UIBlurEffect.Style = .light){
        let blurEffect = UIBlurEffect(style:style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.addSubview(blurEffectView)
        self.updatehudContraints(item: blurEffectView, toItem: self)
    }
    //MARK:-addContentView-
    fileprivate func addContentView(){
        
        hudContentView = JKCardView()
        self.addSubview(hudContentView)
        hudContentView.translatesAutoresizingMaskIntoConstraints = false
        var topConstraint : NSLayoutConstraint
        var bottomConstraint : NSLayoutConstraint
        var widthRelation: NSLayoutConstraint.Relation =  .equal
        if messageString.isEmpty == false {
            widthRelation = hudMode == .HorizontalBar  ? .equal:.lessThanOrEqual
        }
        guard let hudContentView = hudContentView else {return}
        var heightConstant:CGFloat = 0.0
        var widthConstant:CGFloat = 200
        
        switch hudMode {
        case .HorizontalBar:
            heightConstant =  messageString.isEmpty == false ? 55:45
            hudContentView.cornerRadius = 5
            
        default:
            if messageString.isEmpty == false {
                heightConstant = 50
                hudContentView.cornerRadius = 5
            }
            else{
                widthConstant = 45
                heightConstant = 45
                hudContentView.cornerRadius = max(widthConstant, heightConstant)/2
            }
        }
        
        
        //HUD POSITIONS
        
        var layoutConstraints:[NSLayoutConstraint] = [
            widthRelation == .lessThanOrEqual ? hudContentView.widthAnchor.constraint(lessThanOrEqualToConstant: widthConstant):hudContentView.widthAnchor.constraint(equalToConstant: widthConstant),
            hudContentView.heightAnchor.constraint(equalToConstant: heightConstant),
            hudContentView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
            
        ]
        switch hudPosition {
        case .top:
            topConstraint = NSLayoutConstraint(item: hudContentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 80)
            layoutConstraints.append(topConstraint)
        case .bottom:
            bottomConstraint = NSLayoutConstraint(item: hudContentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -40)
            layoutConstraints.append(bottomConstraint)
        default:
            let yConstraint : NSLayoutConstraint = NSLayoutConstraint(item: hudContentView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            layoutConstraints.append(yConstraint)
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        hudContentView.shadowOffset = CGSize(width: 0, height: 0)
        hudContentView.shadowRadius = 7
        hudContentView.isShadow = true
        hudContentView.masksToBounds = false
        hudContentView.clipsToBound = true
        hudContentView.shadowColor = UIColor.black
        hudContentView.backgroundColor = UIColor.white
        hudContentView.setNeedsLayout()
        addHudView()
    }
    //MARK:-addHudView-
    fileprivate func addHudView(){
        
        if hudMode == .HorizontalBar{
            systemBarIndicator  = JKSystemProgressBar()
            systemBarIndicator.progressViewStyle = .bar
            systemBarIndicator.progressTintColor = progressColor
            systemBarIndicator.trackTintColor =  #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
            systemBarIndicator.progress = 0
            systemBarIndicator.cornerRadius = 2.5
            systemBarIndicator.clipsToBound = true
            systemBarIndicator.masksToBounds = true
            if showBarline {
                systemBarIndicator.borderWidth =  lineWidth
                systemBarIndicator.borderColor = lineColor
            }
            hudContentView.addSubview(systemBarIndicator!)
            guard let systemBarIndicator = systemBarIndicator else{return}
            systemBarIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            [
                systemBarIndicator.leadingAnchor.constraint(equalTo: hudContentView.leadingAnchor, constant: 10),
                systemBarIndicator.trailingAnchor.constraint(equalTo: hudContentView.trailingAnchor, constant: -10),
                systemBarIndicator.heightAnchor.constraint(equalToConstant: 10),
                messageString.isEmpty == true ? systemBarIndicator.centerYAnchor.constraint(equalTo: hudContentView.centerYAnchor, constant: 0):systemBarIndicator.topAnchor.constraint(equalTo: hudContentView.topAnchor, constant: 5)
                
                ].forEach({$0.isActive = true})
            systemBarIndicator.setNeedsDisplay()
            
        }else{
            //Indeterminate
            indicatorView  = JKIndicatorView()
            if islineColors {
                indicatorView.colorArray = lineColors
            }else{
                indicatorView.lineColor = lineColor
            }
            indicatorView.lineWidth = (lineWidth > 3) ? lineWidth : 3
            hudContentView.addSubview(indicatorView!)
            
            
            //Indeterminate
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            guard let indicatorView = indicatorView else{return}
            let layoutConstraints = [
                indicatorView.centerYAnchor.constraint(equalTo: hudContentView.centerYAnchor, constant: 0),
                indicatorView.widthAnchor.constraint(equalToConstant:  messageString.isEmpty == false ? 32 : 25),
                indicatorView.heightAnchor.constraint(equalTo: indicatorView.widthAnchor, multiplier: 1),
                messageString.isEmpty == false ?  indicatorView.leadingAnchor.constraint(equalTo: hudContentView.leadingAnchor, constant: 5) :indicatorView.centerXAnchor.constraint(equalTo: hudContentView.centerXAnchor, constant: 0)
            ]
            NSLayoutConstraint.activate(layoutConstraints)
            indicatorView.setNeedsDisplay()
        }
        if messageString.isEmpty == false {
            addLabel()
        }
    }
    
    fileprivate func addLabel(){
        label = UILabel()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = textColor
        label.text = messageString
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        hudContentView.addSubview(label!)
        label.translatesAutoresizingMaskIntoConstraints = false
        if hudMode == .HorizontalBar {
            guard let label = label, let hudContentView = hudContentView else{return}
            let layoutConstraints = [
                label.leadingAnchor.constraint(equalTo: hudContentView.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: hudContentView.trailingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo:systemBarIndicator.topAnchor, constant: 0),
                label.bottomAnchor.constraint(equalTo: hudContentView.bottomAnchor, constant: 0),
                label.heightAnchor.constraint(equalToConstant: 30)
                
            ]
            
            NSLayoutConstraint.activate(layoutConstraints)
            
        }
        else{
            guard let label = label, let hudContentView = hudContentView else{return}
            let layoutConstraints = [
                label.leadingAnchor.constraint(equalTo: indicatorView.rightAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: hudContentView.trailingAnchor, constant: -10),
                label.heightAnchor.constraint(equalToConstant: 30),
                label.centerYAnchor.constraint(equalTo: hudContentView.centerYAnchor, constant: 0)
                
            ]
            NSLayoutConstraint.activate(layoutConstraints)
            label.layoutIfNeeded()
        }
    }
    //MARK:-hideHudafterDelay-
    public func hideHud(animated animate:Bool, afterDelay delay:Int,completion: ((Bool) -> Void)? = nil){
        DispatchQueue.main.after(TimeInterval(delay)) {
            self.hideHud(completion)
        }
    }
    
    //MARK:-hideHud-
    public  func hideHud(_ completion:((Bool) -> Void)? = nil){
        let handler  = {(_ complete:Bool) in
            
            switch self.hudMode {
            case .Indeterminate:
                self.indicatorView?.stopAnimation()
                self.indicatorView?.removeFromSuperview()
                
            case .HorizontalBar:
                self.systemBarIndicator.removeFromSuperview()
                
                
            }
            
            if self.label != nil{
                self.label.removeFromSuperview()
            }
            self.removeFromSuperview()
            completion?(true)
        }
        
        
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.1, animations: {
                self.alpha = 0.0
                
            }, completion: handler)
        }
        
    }
    
    //MARK:-showHud-
    fileprivate func showHud(){
        DispatchQueue.main.async {
            self.initilaize()
            switch self.hudMode{
            case .Indeterminate:
                self.indicatorView?.startAnimation()
            default:break
            }
            
        }
        
    }
    //MARK:-setprogress-
    fileprivate func setProgress(value:Float){
        DispatchQueue.main.async {
            switch self.hudMode {
            case .HorizontalBar:
                if let systemBarIndicator = self.systemBarIndicator {
                    systemBarIndicator.progress = value
                    systemBarIndicator.setNeedsLayout()
                    if self.messageString.isEmpty == false, let label = self.label {
                        label.text = self.messageString
                        self.setNeedsDisplay()
                        
                    }
                    
                    
                }
            default:break
            }
            
        }
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
    }
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if backgroundStyle == .darkBlur {
            let context : CGContext = UIGraphicsGetCurrentContext()!
            UIGraphicsPushContext(context)
            //Gradient colours
            let gradLocationsNum : size_t = 2
            let gradLocations:[CGFloat] = [0.0, 1.0]
            let gradColors:[CGFloat] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.45]
            let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient : CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: gradColors, locations: gradLocations, count: gradLocationsNum)!
            //Gradient center
            let gradCenter:CGPoint = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            //Gradient radius
            let gradRadius:CGFloat = min(self.bounds.size.width , self.bounds.size.height)
            //Gradient draw
            context.drawRadialGradient(gradient, startCenter: gradCenter, startRadius: 0, endCenter: gradCenter, endRadius: gradRadius, options: .drawsAfterEndLocation)
        }
        self.setNeedsDisplay()
        
    }
    
}



//MARK:- JKSystemProgressBar
@IBDesignable
public class JKSystemProgressBar:UIProgressView{
    
    @IBInspectable public var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            self.setNeedsDisplay()
        }
    }
    @IBInspectable public var borderColor: UIColor =  UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
            self.setNeedsDisplay()
            
        }
    }
    @IBInspectable public var borderWidth: CGFloat =  0 {
        didSet {
            layer.borderWidth = borderWidth
            self.setNeedsDisplay()
            
        }
    }
    @IBInspectable public var masksToBounds : Bool = false
        {
        didSet
        {
            layer.masksToBounds = masksToBounds
            self.setNeedsDisplay()
        }
        
    }
    @IBInspectable public var clipsToBound : Bool = false
        {
        didSet
        {
            self.clipsToBounds = clipsToBound
            self.setNeedsDisplay()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}




//MARK:-JKIndicatorView-
@IBDesignable
public class JKIndicatorView: UIView {
    
    fileprivate var strokeLineAnimation: CAAnimationGroup!
    fileprivate var rotationAnimation: CAAnimation!
    fileprivate var strokeColorAnimation: CAAnimation!
    
    /**
     * Array of UIColor
     */
    @IBInspectable public var colorArray:[UIColor] = [UIColor.blue]{
        didSet {
            if colorArray.count < 0  {
                colorArray = [UIColor.blue]
            }
            self.updateAnimations()
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var roundTime = 1.5{
        didSet {
            if roundTime < 1.5 {
                roundTime = 1.5
            }
            self.setNeedsDisplay()
        }
    }
    public var animating: Bool = false
    /**
     * lineWidth of the stroke
     */
    @IBInspectable public var lineWidth:CGFloat = 3.0 {
        didSet {
            circleLayer.lineWidth = lineWidth
            self.setNeedsDisplay()
        }
        
    }
    @IBInspectable public var lineColor:UIColor = UIColor.blue {
        didSet {
            colorArray = [lineColor]
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialSetup()
        
        
    }
    lazy public var circleLayer:CAShapeLayer! = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineWidth = self.lineWidth
        layer.lineCap = CAShapeLayerLineCap.round
        return layer
    }()
    
    
    // MARK: - Initial Setup
    
    fileprivate func initialSetup() {
        
        self.layer.addSublayer(self.circleLayer)
        self.backgroundColor = UIColor.clear
        
        if self.colorArray.count == 0
        {
            self.colorArray = [lineColor]
        }
        
        self.updateAnimations()
    }
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
        let center : CGPoint = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let radius :CGFloat = min(self.bounds.size.width, self.bounds.size.height)/2.0 - self.circleLayer.lineWidth / 2.0
        let startAngle : CGFloat = 0
        let endAngle : CGFloat = 2*CGFloat(mpi)
        let path : UIBezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer.path = path.cgPath
        circleLayer.frame = self.bounds
        
        
    }
    // MARK: -
    
    
    fileprivate func updateAnimations() {
        // Stroke Head
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.beginTime = roundTime / 3.0
        headAnimation.fromValue = 0
        headAnimation.toValue = 1
        headAnimation.duration = 2 * roundTime / 3.0
        headAnimation.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        // Stroke Tail
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.fromValue = 0
        tailAnimation.toValue = 1
        tailAnimation.duration = 2 * roundTime / 3.0
        tailAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)        // Stroke Line Group
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = roundTime
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [headAnimation, tailAnimation]
        self.strokeLineAnimation = animationGroup
        // Rotation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = (2 * mpi)
        rotationAnimation.duration = roundTime
        rotationAnimation.repeatCount = .infinity
        self.rotationAnimation = rotationAnimation
        let strokeColorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
        strokeColorAnimation.values = self.prepareColorValues()
        strokeColorAnimation.keyTimes = self.prepareKeyTimes()
        strokeColorAnimation.calculationMode = CAAnimationCalculationMode.discrete
        strokeColorAnimation.duration = Double(Double(self.colorArray.count) * roundTime)
        strokeColorAnimation.repeatCount = .infinity
        self.strokeColorAnimation = strokeColorAnimation
        self.setNeedsDisplay()
    }
    // MARK: - Animation Data Preparation
    
    fileprivate func prepareColorValues() -> [AnyObject] {
        var cgColorArray = [AnyObject]()
        for color: UIColor in self.colorArray {
            cgColorArray.append(color.cgColor)
            
        }
        return cgColorArray
    }
    
    fileprivate func prepareKeyTimes() -> [NSNumber] {
        var keyTimesArray = [NSNumber]()
        for i in 0..<self.colorArray.count + 1
        {
            keyTimesArray.append(NSNumber(value:  (Float(i)  *  1.0) / Float(self.colorArray.count)))
        }
        return keyTimesArray
    }
    // MARK: -startAnimation
    
    public func startAnimation(){
        self.animating = true
        self.circleLayer.add(self.strokeLineAnimation, forKey: "strokeLineAnimation")
        self.circleLayer.add(self.rotationAnimation, forKey: "rotationAnimation")
        self.circleLayer.add(self.strokeColorAnimation, forKey: "strokeColorAnimation")
    }
    // MARK: -stopAnimation
    public func stopAnimation() {
        self.animating = false
        self.circleLayer.removeAnimation( forKey: "strokeLineAnimation")
        self.circleLayer.removeAnimation( forKey: "rotationAnimation")
        self.circleLayer.removeAnimation( forKey: "strokeColorAnimation")
    }
    
    public  func stopAnimation(after timeInterval: TimeInterval)
    {
        DispatchQueue.main.after(timeInterval) {
            self.stopAnimation()
        }
        // self.perform(#selector(JKIndicatorView.stopAnimation as (JKIndicatorView) -> () -> ()), with: nil, afterDelay: timeInterval)
        
    }
    
    fileprivate func isAnimating() -> Bool {
        return animating
    }}


