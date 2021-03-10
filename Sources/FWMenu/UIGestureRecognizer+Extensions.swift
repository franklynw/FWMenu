//
//  File.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import UIKit


private var actionAssociationKey: UInt8 = 0

extension UIGestureRecognizer {
    
    private var _action: ((UIGestureRecognizer) -> ())? {
        get {
            return objc_getAssociatedObject(self, &actionAssociationKey) as? ((UIGestureRecognizer) -> ())
        }
        set {
            objc_setAssociatedObject(self, &actionAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    class func gestureRecognizer<T: UIGestureRecognizer>(delegate: UIGestureRecognizerDelegate? = nil, action: @escaping (T) -> ()) -> T {
        
        let gestureRecognizer = T(target: self, action: #selector(userDidGesture))
        gestureRecognizer._action = { recognizer in
            action(recognizer as! T)
        }
        gestureRecognizer.delegate = delegate
        
        return gestureRecognizer
    }
    
    @objc private class func userDidGesture(_ sender: UIGestureRecognizer) {
        sender._action?(sender)
    }
}
