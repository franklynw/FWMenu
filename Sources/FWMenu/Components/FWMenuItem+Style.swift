//
//  FWMenuItem+Style.swift
//  
//
//  Created by Franklyn Weber on 12/03/2021.
//

import SwiftUI


extension FWMenuItem {
    
    public enum Style {
        case plain
        case styled(font: Font? = nil, textColor: Color? = nil, iconColor: Color? = nil, backgroundColor: Color? = nil)
        case uiStyled(font: UIFont? = nil, textColor: UIColor? = nil, iconColor: UIColor? = nil, backgroundColor: UIColor? = nil)
        
        func configure(titleLabel: UILabel, icon: UIImageView?, backgroundView: UIView, menuAccentColor: UIColor?, menuFont: UIFont?) {
            
            switch self {
            case .plain:
                
                let color = menuAccentColor ?? .label
                titleLabel.font = menuFont
                titleLabel.textColor = color
                icon?.tintColor = color
                backgroundView.backgroundColor = .clear
                
            case .styled(let font, let textColor, let iconColor, let backgroundColor):
                
                if let font = font {
                    titleLabel.font = font.uiFont()
                } else if let menuFont = menuFont {
                    titleLabel.font = menuFont
                }
                titleLabel.textColor = UIColor(textColor ?? Color(.label))
                icon?.tintColor = UIColor(iconColor ?? textColor ?? Color(.label))
                if let backgroundColor = backgroundColor {
                    backgroundView.backgroundColor = UIColor(backgroundColor)
                } else {
                    backgroundView.backgroundColor = .clear
                }
                
            case .uiStyled(let font, let textColor, let iconColor, let backgroundColor):
                
                if let font = font {
                    titleLabel.font = font
                } else if let menuFont = menuFont {
                    titleLabel.font = menuFont
                }
                titleLabel.textColor = textColor ?? .label
                icon?.tintColor = iconColor ?? textColor
                backgroundView.backgroundColor = backgroundColor ?? .clear
            }
        }
        
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
    }
}
