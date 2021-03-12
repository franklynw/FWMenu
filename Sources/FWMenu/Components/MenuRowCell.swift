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
    
    
    func configure(with menuItem: FWMenuItem, accentColor: UIColor?, font: UIFont?, rowPosition: RowPosition, containingView: UIView?, tapped: @escaping () -> ()) {
        
        titleLabel.text = menuItem.name
        iconImage.image = menuItem.iconImage
        
        menuItem.style.configure(titleLabel: titleLabel, icon: iconImage, backgroundView: backgroundColorView, menuAccentColor: accentColor, menuFont: font)
        
        if titleTrailingConstraint == nil {
            titleTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        }
        if titleImageConstraint == nil {
            titleImageConstraint = titleLabel.trailingAnchor.constraint(equalTo: iconImage.leadingAnchor)
        }
        
        if menuItem.iconImage == nil {
            titleTrailingConstraint.constant = 14
            titleTrailingConstraint.isActive = true
            titleImageConstraint.isActive = false
        } else {
            titleTrailingConstraint.constant = 58
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

