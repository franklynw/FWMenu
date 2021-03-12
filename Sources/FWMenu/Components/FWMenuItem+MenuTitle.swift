//
//  FWMenuItem+MenuTitle.swift
//  
//
//  Created by Franklyn Weber on 12/03/2021.
//

import UIKit


extension FWMenuItem {
    
    public enum MenuTitle {
        
        /*
         Enum for defining the title of a menu
         
         It can be initialised as either a standard title (just a string) or with image and style attributes
         */
        
        /// The standard menu title case
        /// - Parameters:
        ///   - title: the menu title
        case standard(title: String)
        
        /// The styled menu title case
        /// - Parameters:
        ///   - title: the menu title
        ///   - iconImage: an optional image for the menu title
        ///   - style: style attributes for the menu title
        case styled(title: String, iconImage: UIImage? = nil, style: Style)
    }
}


// MARK: - Internal
extension FWMenuItem.MenuTitle {
    
    var text: String {
        switch self {
        case .standard(let title), .styled(let title, _, _):
            return title
        }
    }
    
    var iconImage: UIImage? {
        switch self {
        case .standard:
            return nil
        case .styled(_, let iconImage, _):
            return iconImage
        }
    }
    
    var style: FWMenuItem.Style? {
        switch self {
        case .standard:
            return nil
        case .styled(_, _, let style):
            return style
        }
    }
}
