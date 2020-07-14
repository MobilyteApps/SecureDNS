//
//  DispatchQueue+Ex.swift
//  ChatterBox
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
//MARK: - DispatchQueue Extension -

extension DispatchQueue {
    
    static var userInteractive : DispatchQueue        { return DSQueue.global(.userInteractive).queue }
    static var userInitiated   : DispatchQueue        { return DSQueue.global(.userInitiated).queue   }
    static var utility         : DispatchQueue        { return DSQueue.global(.utility).queue         }
    static var background      : DispatchQueue        { return DSQueue.global(.background).queue      }
    static var unspecified     : DispatchQueue        { return DSQueue.global(.unspecified).queue     }
    
    static func dsQueue(label:String)->DispatchQueue{
        return DSQueue.label(label).queue
    }
    
    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
        
    }
    func syncResult<T>(_ closure: () -> T) -> T {
        var result: T!
        sync { result = closure() }
        return result
    }
}

fileprivate extension DispatchQoS{
    var global:DispatchQueue{
        switch self {
        case .background:
            return DispatchQueue.global(qos: .background)
        case .unspecified:
            return DispatchQueue.global(qos: .unspecified)
        case .userInitiated:
            return DispatchQueue.global(qos: .userInitiated)
        case .userInteractive:
            return DispatchQueue.global(qos: .userInteractive)
        case .utility:
            return DispatchQueue.global(qos: .utility)
        default:
            return DispatchQueue.global(qos: .default)
        }
    }
}

fileprivate enum DSQueue {
    case `default`
    case label(String)
    case global(DispatchQoS)
    
    var queue:DispatchQueue{
        switch self {
        case .global(let qo):
            return qo.global
        case .label(let label):
            return DispatchQueue(label: label)
        default:
            return DispatchQueue.main
        }
    }
    
}
extension DispatchGroup{
    static var group:DispatchGroup {return DispatchGroup()}
    
}


//MARK:- EXTENSION FOR TIMER
extension Timer {
    class func schedule(delay: TimeInterval, handler: ((Timer?) -> Void)!) -> Timer! {
        let fireDate = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, 0, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, .commonModes)
        return timer
    }
    class func schedule(repeatInterval interval: TimeInterval, handler: ((Timer?) -> Void)!) -> Timer! {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, .commonModes)
        return timer
    }
}




