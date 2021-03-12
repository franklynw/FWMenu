//
//  FWMenuItem+MenuTitle.swift
//  
//
//  Created by Franklyn Weber on 12/03/2021.
//

import UIKit


extension FWMenuItem {
    
    public enum MenuTitle {
        case standard(title: String)
        case styled(title: String, iconImage: UIImage? = nil, style: Style)
        
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
        
        var style: Style? {
            switch self {
            case .standard:
                return nil
            case .styled(_, _, let style):
                return style
            }
        }
    }
}
