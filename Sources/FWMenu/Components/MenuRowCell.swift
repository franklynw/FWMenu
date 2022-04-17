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
        case top
        case bottom
        case other
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var backgroundDarkeningView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundBottomConstraint: NSLayoutConstraint!
    
    private var rowBackgroundColor: UIColor?
    
    
    func configure(with menuItem: FWMenuItem, accentColor: UIColor?, backgroundColor: UIColor?, font: UIFont?, rowPosition: RowPosition, containingView: UIView?, tapped: @escaping () -> ()) {
        
        selectionStyle = .none
        
        titleLabel.text = menuItem.name
        iconImage.image = menuItem.iconImage
        backgroundColorView.backgroundColor = backgroundColor // this will be overridden by the style if set
        
        menuItem.style.configure(titleLabel: titleLabel, icon: iconImage, backgroundView: backgroundColorView, menuAccentColor: accentColor, menuFont: font)
        
        rowBackgroundColor = backgroundColorView.backgroundColor?.withAlphaComponent(0.5)
        backgroundColorView.backgroundColor = rowBackgroundColor
        
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
        case .top:
            backgroundTopConstraint.constant = -400
            backgroundBottomConstraint.constant = 0
            lineView.backgroundColor = MenuViewController.sectionHeaderColor
        case .bottom:
            backgroundTopConstraint.constant = 0
            backgroundBottomConstraint.constant = -400
            lineView.backgroundColor = .clear
        case .other:
            backgroundTopConstraint.constant = 0
            backgroundBottomConstraint.constant = 0
            lineView.backgroundColor = MenuViewController.sectionHeaderColor
        }
        
        let tapGestureRecognizer: UITapGestureRecognizer = .gestureRecognizer { _ in
            tapped()
        }
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func select() {
        
        guard let rowBackgroundColor = rowBackgroundColor else {
            return
        }
        
        backgroundDarkeningView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        backgroundColorView.backgroundColor = rowBackgroundColor.withAlphaComponent(0.3)
    }
    
    func deselect() {
        backgroundDarkeningView.backgroundColor = .clear
        backgroundColorView.backgroundColor = rowBackgroundColor
    }
}

