//
//  File.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import UIKit


public struct FWMenuItem {
    let name: String
    let image: UIImage?
    let style: Style
    let action: (() -> ())?
    let submenus: [FWMenuItem]?
    
    var hasSubmenus: Bool {
        return submenus != nil
    }
    
    public enum Style {
        case plain
        case colored(textColor: UIColor, iconColor: UIColor? = nil, backgroundColor: UIColor? = nil)
    }
    
    public init(name: String, imageName: String? = nil, style: Style = .plain, action: @escaping (() -> ())) {
        self.name = name
        if let imageName = imageName {
            image = UIImage(named: imageName)
        } else {
            image = nil
        }
        self.style = style
        self.action = action
        submenus = nil
    }
    
    public init(name: String, systemImageName: String, style: Style = .plain, action: @escaping (() -> ())) {
        self.name = name
        image = UIImage(systemName: systemImageName)
        self.style = style
        self.action = action
        submenus = nil
    }
    
    public init(name: String, style: Style = .plain, submenus: [FWMenuItem]) {
        self.name = name
        self.style = style
        self.submenus = submenus
        image = nil
        action = nil
    }
}
