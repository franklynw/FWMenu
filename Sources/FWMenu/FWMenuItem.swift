//
//  File.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI


public struct FWMenuItem {
    let name: String
    let image: UIImage?
    let style: Style
    let action: (() -> ())?
    let submenuSections: [[FWMenuItem]]?
    
    var hasSubmenus: Bool {
        return submenuSections != nil
    }
    
    public enum Style {
        case plain
        case styled(font: Font? = nil, textColor: Color, iconColor: Color? = nil, backgroundColor: Color? = nil)
        case uiStyled(font: UIFont? = nil, textColor: UIColor, iconColor: UIColor? = nil, backgroundColor: UIColor? = nil)
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
        submenuSections = nil
    }
    
    public init(name: String, systemImageName: String, style: Style = .plain, action: @escaping (() -> ())) {
        self.name = name
        image = UIImage(systemName: systemImageName)
        self.style = style
        self.action = action
        submenuSections = nil
    }
    
    public init(name: String, style: Style = .plain, submenuSections: [[FWMenuItem]]) {
        self.name = name
        self.style = style
        self.submenuSections = submenuSections
        image = nil
        action = nil
    }
    
    public init(name: String, style: Style = .plain, submenuItems: [FWMenuItem]) {
        self.init(name: name, style: style, submenuSections: [submenuItems])
    }
}
