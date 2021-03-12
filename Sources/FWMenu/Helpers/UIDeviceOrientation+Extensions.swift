//
//  UIDeviceOrientation+Extensions.swift
//  
//
//  Created by Franklyn Weber on 12/03/2021.
//

import UIKit


extension UIDeviceOrientation {
    
    func isAspectEqual(to orientation: UIDeviceOrientation) -> Bool {
        
        switch (self.isLandscape, orientation.isLandscape) {
        case (true, true), (false, false):
            return true
        default:
            return false
        }
    }
}
