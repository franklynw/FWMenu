//
//  FWMenuPresenting.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


public protocol FWMenuPresenting {
    var content: () -> ([FWMenuSection]) { get }
    var menuType: FWMenuType { get }
    var contentBackgroundColor: Color? { get }
    var contentAccentColor: Color? { get }
    var font: Font? { get }
    var hideMenuOnDeviceRotation: Bool { get }
}


public extension FWMenuPresenting {
    
    var menuType: FWMenuType {
        return .standard
    }
    
    var hideMenuOnDeviceRotation: Bool {
        return false
    }
}
