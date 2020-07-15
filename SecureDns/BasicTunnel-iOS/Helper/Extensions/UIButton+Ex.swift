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
