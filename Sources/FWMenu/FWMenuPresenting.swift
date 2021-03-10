//
//  FWMenuPresenting.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


public protocol FWMenuPresenting {
    var content: () -> ([[FWMenuItem]]) { get }
    var contentBackgroundColor: Color? { get }
    var contentAccentColor: Color? { get }
    var font: Font? { get }
}
