//
//  JKSwitch.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 30/07/20.
//  Copyright © 2020 Mobilyte Inc.. All rights reserved.
//

import UIKit
import NetworkExtension


@IBDesignable
class JKSwitch: UIView {
   public var didOnChange:((_ isOn:Bool)->Void)?
    private lazy var titleLabel:UILabel = {
        
        let label  = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
   private lazy var detailLabel:UILabel = {
        
        let label  = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    private lazy var indicator:JKIndicatorView = {
        let loader = JKIndicatorView()
        loader.lineColor = UIColor.greenColor
        loader.lineWidth = 2
        loader.backgroundColor = .white
        loader.translatesAutoresizingMaskIntoConstraints = false
        return loader
    }()
    private lazy var swtichBtn:UISwitch = {
        let control = UISwitch()
        control.onTintColor = self.onTintColor
        control.thumbTintColor = .white
        control.isUserInteractionEnabled = true
        control.isEnabled = true
        control.translatesAutoresizingMaskIntoConstraints = false
        
        return control
    }()
    @IBInspectable
   public var size:CGSize = .init(width: 160, height: 90){
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable
   public var onTintColor:UIColor = UIColor.greenColor{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable
   public var offTintColor:UIColor = #colorLiteral(red: 0.2588235294, green: 0.2784313725, blue: 0.4078431373, alpha: 1){
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable
   public var thumbTintColor:UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0){
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
   public var isAnimating:Bool = false{
        didSet{
            if isAnimating {
                hidesWhenStopped = false
                indicator.startAnimation()
            }else{
                indicator.stopAnimation()
                hidesWhenStopped = true
            }
            self.setNeedsDisplay()
        }
    }
    @IBInspectable
   public var hidesWhenStopped:Bool = false{
        didSet{
            if hidesWhenStopped == true {
                self.indicator.isHidden = true
            }else{
                self.indicator.isHidden = false
            }
            self.setNeedsDisplay()
            
        }
    }
    @IBInspectable
   public var isOn: Bool = false{
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable
    public var title: String = NEVPNStatus.invalid.title.uppercased(){
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable
   public var subTitle: String = NEVPNStatus.invalid.description.uppercased(){
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    private func initialize() {
        self.clearChildViews()
        
        addSubview(swtichBtn)
        swtichBtn.addSubview(indicator)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,detailLabel])
        stack.alignment = .fill
        stack.axis = .vertical
        stack.spacing = 10
        addSubview(stack)
        
        
        
        swtichBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        swtichBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        swtichBtn.centerXAnchor.constraint(equalToSystemSpacingAfter: self.centerXAnchor, multiplier: 1.0).isActive = true
        swtichBtn.heightAnchor.constraint(equalToConstant: size.height).isActive = false
        swtichBtn.widthAnchor.constraint(equalToConstant: size.width).isActive = false
        
        indicator.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        indicator.widthAnchor.constraint(equalTo: indicator.heightAnchor, multiplier: 1.0).isActive = true
        indicator.rightAnchor.constraint(equalTo: swtichBtn.rightAnchor, constant:size.width/3).isActive = true
        indicator.centerYAnchor.constraint(equalToSystemSpacingBelow: swtichBtn.centerYAnchor, multiplier: 1.0).isActive = true
        
        stack.topAnchor.constraint(equalTo: swtichBtn.bottomAnchor, constant: 10).isActive = true
        stack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10).isActive = true
        
        swtichBtn.addAction(for: .valueChanged) { _ in
           
            self.swtichBtn.onTintColor = self.swtichBtn.isOn ? self.onTintColor : self.offTintColor
            self.didOnChange?(self.swtichBtn.isOn)
        }
        
    }
    
   public func setStatus(_ status:NEVPNStatus){
        titleLabel.text = status.title.uppercased()
        detailLabel.text = status.description
        DispatchQueue.main.after(0.3) {
            if status == .connecting {
                self.isAnimating = true
            }else{
                self.isAnimating = false
            }
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        swtichBtn.set(width: size.width, height: size.height)
        self.swtichBtn.onTintColor = self.swtichBtn.isOn ? self.onTintColor : self.offTintColor
        self.swtichBtn.thumbTintColor = thumbTintColor
        self.swtichBtn.setOn(isOn, animated: true)
        self.titleLabel.text = title
        self.detailLabel.text = subTitle
        self.setNeedsDisplay()
        
    }
    
    
}
