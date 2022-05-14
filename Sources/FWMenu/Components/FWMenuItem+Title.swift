//
//  FWMenuItem+Title.swift
//  
//
//  Created by Franklyn Weber on 12/03/2021.
//

import SwiftUI


extension FWMenuItem {
    
    public enum Title {
        
        /*
         Enum for defining the title of a menu
         
         It can be initialised as either a standard title (just a string) or with image and style attributes
         */
        
        public enum TitleStyle {
            case plain
            case styled(font: Font? = nil, textColor: Color? = nil, iconColor: Color? = nil, backgroundColor: Color? = nil)
            case uiStyled(font: UIFont? = nil, textColor: UIColor? = nil, iconColor: UIColor? = nil, backgroundColor: UIColor? = nil)
        }
        
        /// The standard menu title case
        /// - Parameters:
        ///   - title: the menu title
        case standard(title: String)
        
        /// The styled menu title case
        /// - Parameters:
        ///   - title: the menu title
        ///   - iconImage: an optional image for the menu title
        ///   - style: style attributes for the menu title
        case styled(title: String, iconImage: UIImage? = nil, style: TitleStyle)
        
        public func applyToLabel(_ label: UILabel, imageView: UIImageView? = nil, backgroundView: UIView? = nil) {
            
            label.text = text
            imageView?.image = iconImage
            
            style?.configure(titleLabel: label, icon: imageView, backgroundView: backgroundView, menuAccentColor: nil, menuFont: nil)
        }
    }
}


// MARK: - Internal
extension FWMenuItem.Title {
    
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
    
    var style: FWMenuItem.Title.TitleStyle? {
        switch self {
        case .standard:
            return nil
        case .styled(_, _, let style):
            return style
        }
    }
}


extension FWMenuItem.Title.TitleStyle {
    
    var backgroundColor: UIColor? {
        switch self {
        case .plain:
            return nil
        case .styled(_, _, _, let backgroundColor):
            return backgroundColor != nil ? UIColor(backgroundColor!) : nil
        case .uiStyled(_, _, _, let backgroundColor):
            return backgroundColor
        }
    }
    
    func configure(titleLabel: UILabel, icon: UIImageView?, backgroundView: UIView?, menuAccentColor: UIColor?, menuFont: UIFont?) {
        
        switch self {
        case .plain:
            
            let color = menuAccentColor ?? .label
            titleLabel.font = menuFont
            titleLabel.textColor = color
            icon?.tintColor = color
            
        case .styled(let font, let textColor, let iconColor, let backgroundColor):
            
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
            
        case .uiStyled(let font, let textColor, let iconColor, let backgroundColor):
            
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
}
