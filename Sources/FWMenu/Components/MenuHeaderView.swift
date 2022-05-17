//
//  MenuHeaderView.swift
//  
//
//  Created by Franklyn Weber on 12/03/2021.
//

import SwiftUI


class MenuHeaderView: UIView {
    
    private static let font = UIFont.boldSystemFont(ofSize: 17)
    private let title: FWMenuItem.Title
    
    var size: CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let menuPadding = WindowViewController.menuPadding
        let rowPadding: CGFloat = 32
        let availableWidth = screenSize.width - menuPadding * 2
        
        let maxTextWidth: CGFloat
        let additionalPadding: CGFloat
        if title.iconImage == nil {
            maxTextWidth = availableWidth - rowPadding
            additionalPadding = rowPadding
        } else {
            maxTextWidth = availableWidth - rowPadding - 42
            additionalPadding = rowPadding + 42
        }
        
        let size = title.text.boundingRect(with: CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: Self.font], context: nil).size
        
        let width = size.width + additionalPadding
        let height = size.height + 22.5
        
        return CGSize(width: width, height: height)
    }
    
    
    init(title: FWMenuItem.Title, backgroundColor: UIColor, menuAccentColor: UIColor?) {
        
        self.title = title
        
        super.init(frame: .zero)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = title.text
        
        addSubview(label)
        
        let constraints: [NSLayoutConstraint] = [
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 11),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -11)
        ]
        
        constraints.forEach { $0.priority = UILayoutPriority(999) }
        
        NSLayoutConstraint.activate(constraints)
        
        let iconImageView: UIImageView?
        
        if let iconImage = title.iconImage {
            
            let icon = UIImageView(image: iconImage)
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.contentMode = .scaleAspectFill
            
            icon.widthAnchor.constraint(equalToConstant: 30).isActive = true
            
            addSubview(icon)
            
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: icon.leadingAnchor, constant: -14.0),
                icon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
                icon.centerYAnchor.constraint(equalTo: label.centerYAnchor)
            ])
            
            iconImageView = icon
            
        } else {
            iconImageView = nil
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0).isActive = true
        }
        
        let style = title.style ?? .plain
        
        style.configure(titleLabel: label, icon: iconImageView, backgroundView: self, menuAccentColor: menuAccentColor, menuFont: Self.font)
        self.backgroundColor = title.style?.backgroundColor ?? backgroundColor
        
        let tapGesture: UITapGestureRecognizer = .gestureRecognizer { _ in
            // nothing, just stops the menu being dismissed if the user taps the header
        }
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
