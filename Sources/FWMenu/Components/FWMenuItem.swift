//
//  FWMenuItem.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI


public enum FWMenuItem {
    
    /*
     Enum for defining menu items in a FWMenu
     
     It can be initialised as a standard menu item, with text, icon and action, or as an item with a sub-menu (with only the title definable)
     Each menu item can be styled using the Style enum, which allows customisation of text & background colour, & font
     The style setting for a menu item will override the global setting for the menu
     */
    
    /// The case for an action menu item
    /// - Parameters:
    ///   - name: the menu item name (as it appears in the menu)
    ///   - imageName: the name of an image for the menu item icon (nil for no image)
    ///   - systemImageName: the name of a system image for the menu item icon (nil for no image)
    ///   - style: the style for the menu item
    ///   - action: the action invoked when the menu item is selected
    case action(name: String, imageName: String? = nil, systemImageName: String?, style: Style = .plain(), action: (() -> ()))
    
    /// The case for a menu item with submenus
    /// - Parameters:
    ///   - name: the menu item name (as it appears in the menu)
    ///   - style: the style for the menu item
    ///   - menuSections: the content for the submenus
    case submenu(name: String, style: Style = .plain(), menuSections: [FWMenuSection])
    
    /// Creates an action menu item
    /// - Parameters:
    ///   - name: the menu item name (as it appears in the menu)
    ///   - imageName: the name of an image for the menu item icon (nil for no image)
    ///   - style: the style for the menu item
    ///   - action: the action invoked when the menu item is selected
    /// - Returns: the .action enum case, with the provided parameters
    public static func action(name: String, imageName: String? = nil, style: Style = .plain(), action: @escaping (() -> ())) -> FWMenuItem {
        return .action(name: name, imageName: imageName, systemImageName: nil, style: style, action: action)
    }
    
    /// Creates an action menu item
    /// - Parameters:
    ///   - name: the menu item name (as it appears in the menu)
    ///   - systemImageName: the name of a system image for the menu item icon (nil for no image)
    ///   - style: the style for the menu item
    ///   - action: the action invoked when the menu item is selected
    /// - Returns: the .action enum case, with the provided parameters
    public static func action(name: String, systemImageName: String, style: Style = .plain(), action: @escaping (() -> ())) -> FWMenuItem {
        return .action(name: name, imageName: nil, systemImageName: systemImageName, style: style, action: action)
    }
    
    /// Creates a menu item with submenus
    /// - Parameters:
    ///   - name: the menu item name (as it appears in the menu)
    ///   - style: the style for the menu item
    ///   - menuItems: the content for the submenus
    public static func submenu(name: String, style: Style = .plain(), menuItems: FWMenuSection) -> FWMenuItem {
        return .submenu(name: name, style: style, menuSections: [menuItems])
    }
}


// MARK: - Internal
extension FWMenuItem {
    
    var name: String {
        switch self {
        case .action(let name, _, _, _, _), .submenu(let name, _, _):
            return name
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .action(_, let imageName, let systemImageName, _, _):
            if let imageName = imageName {
                return UIImage(named: imageName)
            } else if let systemImageName = systemImageName {
                return UIImage(systemName: systemImageName)
            }
            return nil
        case .submenu:
            return UIImage(systemName: "chevron.right")
        }
    }
    
    var style: Style {
        switch self {
        case .action(_, _, _, let style, _), .submenu(_, let style, _):
            return style
        }
    }
    
    var action: () -> () {
        switch self {
        case .action(_, _, _, _, let action):
            return action
        case .submenu:
            return {}
        }
    }
    
    var hasSubmenus: Bool {
        if case .submenu = self {
            return true
        }
        return false
    }
    
    var menuSections: [FWMenuSection] {
        switch self {
        case .action:
            return []
        case .submenu(_, _, let menuSections):
            return menuSections
        }
    }
    
    var menuTitle: Title? {
        switch self {
        case .action(_, _, _, let style, _), .submenu(_, let style, _):
            let title: FWMenuItem.Title?
            switch style.menuHeading {
            case .none: title = nil
            case .menuItem: title = .standard(title: name)
            case .title(let menuTitle): title = menuTitle
            }
            return title
        }
    }
}


public struct FWMenuSection {
    
    /*
     Struct for defining menu sections in a FWMenu
     
     Contains an array of FWMenuItem
     */
    
    let menuItems: [FWMenuItem]
    
    public init(_ menuItems: [FWMenuItem]) {
        self.menuItems = menuItems
    }
}
