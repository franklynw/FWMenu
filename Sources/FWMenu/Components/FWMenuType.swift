//
//  FWMenuType.swift
//  
//
//  Created by Franklyn Weber on 10/03/2021.
//

import Foundation


public enum FWMenuType {
    case standard(title: FWMenuItem.MenuTitle? = nil)
    case settings(title: FWMenuItem.MenuTitle? = nil)
    
    public static let standard: FWMenuType = .standard()
    public static let settings: FWMenuType = .settings()
    
    var menuTitle: FWMenuItem.MenuTitle? {
        switch self {
        case .standard(let title), .settings(let title):
            return title
        }
    }
}
