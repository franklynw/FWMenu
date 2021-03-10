//
//  FWMenuPresenting.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


public protocol FWMenuPresenting {
    var content: () -> ([[FWMenuItem]]) { get }
    var menuType: FWMenuType { get }
    var contentBackgroundColor: Color? { get }
    var contentAccentColor: Color? { get }
    var font: Font? { get }
}


public extension FWMenuPresenting {
    
    var menuType: FWMenuType {
        return .standard
    }
}
