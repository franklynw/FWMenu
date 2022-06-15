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
    /// NB - the underlying data structure of the menus should remain unaltered when items are selected, as the resulting behaviour is undefined and may crash
    /// It's fine to update menu item values, but try to avoid changing the tree structure of the presented menus
    public var settingsMenu: Self {
        var copy = self
        let menuTitle = copy.menuType.menuTitle
        copy.menuType = .settings(title: menuTitle)
        return copy
    }
    
    public func getFrame(getFrame: @escaping (CGRect) -> ()) -> Self {
        var copy = self
        copy.getFrame = getFrame
        return copy
    }
    
    /// A special-use case for when the menu is presented from a keyboard accessory bar - otherwise the keyboard hides & the menu is left floating only in the top half of the screen
    public func forceFullScreen(_ forceFullScreen: Bool) -> Self {
        var copy = self
        copy.forceFullScreen = forceFullScreen
        return copy
    }
    
    /// How to display the menu button if there is no menu content
    /// - Parameter pressed: a closure invoked when the menu button is tapped (in addition to showing the menu)
    public func pressed(_ pressed: @escaping () -> ()) -> Self {
        var copy = self
        copy.pressed = pressed
        return copy
    }
}
