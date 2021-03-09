//
//  MenuRowCell.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


class MenuRowCell: UITableViewCell {
    
    static let cellIdentifier = "MenuRow"
    
    enum RowPosition {
        case bottom
        case other
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleImageConstraint: NSLayoutConstraint!
    
    private let lineColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    
    
    func configure(with menuItem: FWMenuItem, accentColor: Color?, font: Font?, rowPosition: RowPosition, containingView: UIView?, tapped: @escaping () -> ()) {
        
        titleLabel.text = menuItem.name
        
        if menuItem.hasSubmenus {
            iconImage.image = UIImage(systemName: "chevron.right")
        } else {
            iconImage.image = menuItem.image
        }
        
        switch menuItem.style {
        case .plain:
            let color = accentColor != nil ? UIColor(accentColor!) : .label
            titleLabel.font = nil
            titleLabel.textColor = color
            iconImage.tintColor = color
            backgroundColorView.backgroundColor = .clear
        case .styled(let font, let textColor, let iconColor, let backgroundColor):
            if let font = font {
                titleLabel.font = font.uiFont()
            }
            titleLabel.textColor = UIColor(textColor)
            iconImage.tintColor = UIColor(iconColor ?? textColor)
            if let backgroundColor = backgroundColor {
                backgroundColorView.backgroundColor = UIColor(backgroundColor)
            } else {
                backgroundColorView.backgroundColor = .clear
            }
        case .uiStyled(let font, let textColor, let iconColor, let backgroundColor):
            if let font = font {
                titleLabel.font = font
            }
            titleLabel.textColor = textColor
            iconImage.tintColor = iconColor ?? textColor
            backgroundColorView.backgroundColor = backgroundColor ?? .clear
        }
        
        if titleTrailingConstraint == nil {
            titleTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        }
        if titleImageConstraint == nil {
            titleImageConstraint = titleLabel.trailingAnchor.constraint(equalTo: iconImage.leadingAnchor)
        }
        
        if menuItem.image == nil {
            titleTrailingConstraint.constant = menuItem.image == nil ? 14 : 58
            titleTrailingConstraint.isActive = true
            titleImageConstraint.isActive = false
        } else {
            titleImageConstraint.isActive = true
            titleTrailingConstraint.isActive = false
        }
        
        switch rowPosition {
        case .bottom:
            lineView.backgroundColor = .clear
        case .other:
            lineView.backgroundColor = lineColor
        }
        
        let tapGestureRecognizer: UITapGestureRecognizer = .gestureRecognizer { _ in
            tapped()
        }
        addGestureRecognizer(tapGestureRecognizer)
    }
}

