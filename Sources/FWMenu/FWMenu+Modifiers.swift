//
//  FWMenu+Modifiers.swift
//  
//
//  Created by Franklyn Weber on 10/03/2021.
//

import SwiftUI


extension FWMenu {
    
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
    
    /// The accent colour for the menu button
    /// - Parameter accentColor: a Color value
    public func accentColor(_ accentColor: Color) -> Self {
        var copy = self
        copy.accentColor = accentColor
        return copy
    }
    
    /// Sets the global font for the menu content - only in Beta, and only works with system fonts with no modifiers such as weight, etc
    /// - Parameter font: a Font value
    public func font(_ font: Font) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
    
    /// How to display the menu button if there is no menu content
    /// - Parameter hidePolicy: a HidePolicy case
    public func hidePolicyWhenNoItems(_ hidePolicy: HidePolicy) -> Self {
        var copy = self
        copy.hidePolicy = hidePolicy
        return copy
    }
    
    /// Set this if the menus don't rotate nicely, as support for device rotation hasn't been added yet
    public var dismissOnDeviceRotation: Self {
        var copy = self
        copy.hideMenuOnDeviceRotation = true
        return copy
    }
    
    /// Turns the menu into a settings menu, where each new menu is presented above the current menu, and content is updated when the data model changes
    /// NB - this is currently in an early development stage, and will only work properly if the underlying data structure of the menus is unaltered when items are selected
    /// It's fine to update menu item values, but not their content (ie, sub-menus) - behaviour here is undefined and will probably crash
    public var settingsMenu: Self {
        var copy = self
        copy.menuType = .settings
        return copy
    }
}
