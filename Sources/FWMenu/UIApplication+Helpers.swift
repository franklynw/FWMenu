//
//  UIApplication+Helpers.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import UIKit


extension UIApplication {
    
    static var window: UIWindow? {
        return UIApplication.shared.windows.filter { $0.isKeyWindow }.first
    }
    
    static func endEditing() {
        window?.endEditing(true)
    }
}
