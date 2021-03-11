//
//  FWMenuPresenter+Modifiers.swift
//  
//
//  Created by Franklyn Weber on 10/03/2021.
//

import SwiftUI


extension FWMenuPresenter {
    
    /// Sets the global menu background colour
    /// - Parameter contentBackgroundColor: a Color value
    public func contentBackgroundColor(_ contentBackgroundColor: Color) -> Self {
        var copy = self
        copy.contentBackgroundColor = contentBackgroundColor
        return copy
    }
    
    /// Sets the global menu text & icon colour
    /// - Parameter contentAccentColor: a Color value
    public func contentAccentColor(_ contentAccentColor: Color) -> Self {
        var copy = self
        copy.contentAccentColor = contentAccentColor
        return copy
    }
    
    /// Sets the global font for the menu content - only in Beta, and only works with system fonts with no modifiers such as weight, etc
    /// - Parameter font: a Font value
    public func font(_ font: Font) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
    
    /// Set this if the menus don't rotate nicely, as support for device rotation hasn't been added yet
    public var dismissOnDeviceRotation: Self {
        var copy = self
        copy.hideMenuOnDeviceRotation = true
        return copy
    }
}
