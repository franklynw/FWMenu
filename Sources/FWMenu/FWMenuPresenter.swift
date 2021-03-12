//
//  FWMenuPresenter.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


public struct FWMenuPresenter: View, FWMenuPresenting {
    
    @Binding private var isPresented: Bool
    
    public let content: () -> ([FWMenuSection])
    
    public var menuType: FWMenuType
    public var contentBackgroundColor: Color?
    public var contentAccentColor: Color?
    public var font: Font?
    public var hideMenuOnDeviceRotation = false

    private let sourceRect: CGRect?

    
    public init(isPresented: Binding<Bool>, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sourceRect: CGRect? = nil, menuSections: @escaping () -> [FWMenuSection]) {
        _isPresented = isPresented
        content = menuSections
        menuType = .standard(title: initialMenuTitle)
        self.sourceRect = sourceRect
    }
    
    public init(isPresented: Binding<Bool>, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sourceRect: CGRect? = nil, menuItems: @escaping () -> FWMenuSection) {
        _isPresented = isPresented
        content = { () -> [FWMenuSection] in
            return [menuItems()]
        }
        menuType = .standard(title: initialMenuTitle)
        self.sourceRect = sourceRect
    }
    
    public init(isPresented: Binding<Bool>, sourceRect: CGRect? = nil, menu: @escaping () -> FWMenuItem) {
        _isPresented = isPresented
        content = { () -> [FWMenuSection] in
            return menu().menuSections
        }
        menuType = .standard(title: menu().menuTitle)
        self.sourceRect = sourceRect
    }
    
    
    public var body: some View {
        
        DoIf($isPresented) {
            MenuPresenter.present(parent: self, with: sourceRect)
            isPresented = false
        }
    }
}
