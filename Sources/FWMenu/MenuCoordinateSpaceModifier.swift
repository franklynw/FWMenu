//
//  MenuCoordinateSpaceModifier.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI


public struct MenuCoordinateSpaceModifier: ViewModifier {
    
    internal static let menuCoordinateSpaceName = "FWMenu"
    
    public func body(content: Content) -> some View {
        content
            .coordinateSpace(name: Self.menuCoordinateSpaceName)
    }
}


public extension View {
    
    var menuCoordinateSpace: ModifiedContent<Self, MenuCoordinateSpaceModifier> {
        self.modifier(MenuCoordinateSpaceModifier())
    }
}
