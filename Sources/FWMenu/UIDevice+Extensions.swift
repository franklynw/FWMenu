//
//  UIDevice+Extensions.swift
//  
//
//  Created by Franklyn Weber on 10/03/2021.
//

import UIKit


extension UIDevice {
    
    static var hasNotch: Bool {
        return UIApplication.window?.safeAreaInsets.top ?? 0 > 20
    }
}
