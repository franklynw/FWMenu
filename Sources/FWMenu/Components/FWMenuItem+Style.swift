//
//  FWMenuItem+Style.swift
//  
//
//  Created by Franklyn Weber on 12/03/2021.
//

import SwiftUI


extension FWMenuItem {
    
    public enum Style {
        
        /*
         Enum for defining the style of menu elements
         
         It can be initialised as plain (uses menu defaults), styled or uiStyled - the styled cases allow customisation of font, text colour, icon colour & background colour
         */
        
        public enum MenuHeading {
            case none
            case menuItem
            case title(Title)
        }
        
        /// The plain style case
        /// - Parameters:
        ///   - menuHeading: any heading for the menu
        case plain(menuHeading: MenuHeading = .none)
        
        /// The styled case
        /// - Parameters:
        ///   - menuHeading: any heading for the menu
        ///   - font: the SwiftUI Font to use for the element
        ///   - textColor: the SwiftUI Color to use for the element text
        ///   - iconColor: the SwiftUI Color to use for the element icon
        ///   - backgroundColor: the SwiftUI Color to use for the element background
        case styled(menuHeading: MenuHeading = .none, font: Font? = nil, textColor: Color? = nil, iconColor: Color? = nil, backgroundColor: Color? = nil)
        
        /// The styled case
        /// - Parameters:
        ///   - menuHeading: any heading for the menu
        ///   - font: the UIFont to use for the element
        ///   - textColor: the UIColor to use for the element text
        ///   - iconColor: the UIColor to use for the element icon
        ///   - backgroundColor: the UIColor to use for the element background
        case uiStyled(menuHeading: MenuHeading = .none, font: UIFont? = nil, textColor: UIColor? = nil, iconColor: UIColor? = nil, backgroundColor: UIColor? = nil)
    }
}


// MARK: - Internal
extension FWMenuItem.Style {
    
    func configure(titleLabel: UILabel, icon: UIImageView?, backgroundView: UIView?, menuAccentColor: UIColor?, menuFont: UIFont?) {
        
        switch self {
        case .plain:
            
            let color = menuAccentColor ?? .label
            titleLabel.font = menuFont
            titleLabel.textColor = color
            icon?.tintColor = color
            
        case .styled(_, let font, let textColor, let iconColor, let backgroundColor):
            
            if let font = font {
                titleLabel.font = font.uiFont()
            } else if let menuFont = menuFont {
                titleLabel.font = menuFont
            }
            titleLabel.textColor = UIColor(textColor ?? Color(.label))
            icon?.tintColor = UIColor(iconColor ?? textColor ?? Color(.label))
            if let backgroundColor = backgroundColor {
                backgroundView?.backgroundColor = UIColor(backgroundColor)
            }
            
        case .uiStyled(_, let font, let textColor, let iconColor, let backgroundColor):
            
            if let font = font {
                titleLabel.font = font
            } else if let menuFont = menuFont {
                titleLabel.font = menuFont
            }
            titleLabel.textColor = textColor ?? .label
            icon?.tintColor = iconColor ?? textColor
            if let backgroundColor = backgroundColor {
                backgroundView?.backgroundColor = backgroundColor
            }
        }
    }
    
    var backgroundColor: UIColor? {
        switch self {
        case .plain:
            return nil
        case .styled(_, _, _, _, let backgroundColor):
            return backgroundColor != nil ? UIColor(backgroundColor!) : nil
        case .uiStyled(_, _, _, _, let backgroundColor):
            return backgroundColor
        }
    }
    
    var menuHeading: MenuHeading {
        switch self {
        case .plain(let heading), .styled(let heading, _, _, _, _), .uiStyled(let heading, _, _, _, _):
            return heading
        }
    }
}
