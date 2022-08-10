//
//  FWMenuType.swift
//  
//
//  Created by Franklyn Weber on 10/03/2021.
//

import Foundation


public enum FWMenuType {
    
    /*
     Enum for defining the type of the menu
     
     Can be either a standard menu (behaves almost identically to Apple's Menu) or a Settings menu,
     where the entire menu tree remains on screen while submenus are presented,
     and menu values update according to the data model
     */
    
    /// The standard case
    /// - Parameters:
    ///   - title: an optional title for the menu
    case standard(title: FWMenuItem.Title? = nil, presentedFromKeyboardAccessory: Bool = false, hideOnDeviceRotation: Bool = false)
    
    /// The settings case
    /// - Parameters:
    ///   - title: an optional title for the menu
    case settings(title: FWMenuItem.Title? = nil, presentedFromKeyboardAccessory: Bool = false, hideOnDeviceRotation: Bool = false)
    
    /// Returns a .standard FWMenuType, with no title
    public static let standard: FWMenuType = .standard()
    
    /// Returns a .settings FWMenuType, with no title
    public static let settings: FWMenuType = .settings()
}
    

// MARK: - Internal
extension FWMenuType {
    
    var menuTitle: FWMenuItem.Title? {
        switch self {
        case .standard(let title, _, _), .settings(let title, _, _):
            return title
        }
    }
    
    var presentedFromKeyboardAccessory: Bool {
        switch self {
        case .standard(_, let presentedFromKeyboardAccessory, _), .settings(_, let presentedFromKeyboardAccessory, _):
            return presentedFromKeyboardAccessory
        }
    }
    
    var hideOnDeviceRotation: Bool {
        switch self {
        case .standard(_, _, let hideOnDeviceRotation), .settings(_, _, let hideOnDeviceRotation):
            return hideOnDeviceRotation
        }
    }
}
