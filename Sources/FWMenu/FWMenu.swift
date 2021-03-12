//
//  FWMenu.swift
//
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


public struct FWMenu<Label: View>: View, FWMenuPresenting {
    
    /*
     A replacement for Apple's Menu struct, but more customisable
     Also addresses an issue in Apple's version where the background continues to receive touch events while the menu is showing
     */
    
    @Binding private var isPresented: Bool
    
    public let content: () -> ([FWMenuSection])
    
    public var menuType: FWMenuType // TODO: - FWMenuType.settings is somewhat fragile, & will probably crash if the client code alters the structure of the menus after an item is selected
    public var contentBackgroundColor: Color?
    public var contentAccentColor: Color?
    public var font: Font?
    public var hideMenuOnDeviceRotation = false
    
    var accentColor: Color?
    var hidePolicy: HidePolicy = .alwaysShow
    
    private let label: Label?
    private let image: Image?
    private let title: String?
    private let imageName: String?
    
    public enum HidePolicy: Equatable {
        case alwaysShow
        case dim(opacity: Double)
        case hide
        
        var opacity: Double {
            switch self {
            case .alwaysShow: return 1
            case .dim(let opacity): return opacity
            case .hide: return 0
            }
        }
    }
    
    
    private init(title: String?, image: Image?, imageSystemName: String?, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sections: @escaping () -> ([FWMenuSection])) where Label == Text {
        self.title = title
        self.image = image
        imageName = imageSystemName
        content = { () -> [FWMenuSection] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        menuType = .standard(title: initialMenuTitle)
        label = nil
        _isPresented = Binding<Bool>(get: { false }, set: { _ in })
    }
    
    
    // MARK: - Initialise with an array of FWMenuSection
    
    public init(label: Label, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sections: @escaping () -> ([FWMenuSection])) {
        self.label = label
        content = { () -> [FWMenuSection] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        menuType = .standard(title: initialMenuTitle)
        image = nil
        title = nil
        imageName = nil
        _isPresented = Binding<Bool>(get: { false }, set: { _ in })
    }
    
    public init(title: String, imageSystemName: String, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sections: @escaping () -> ([FWMenuSection])) where Label == Text {
        self.init(title: title, image: nil, imageSystemName: imageSystemName, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(title: String, image: Image, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sections: @escaping () -> ([FWMenuSection])) where Label == Text {
        self.init(title: title, image: image, imageSystemName: nil, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(title: String, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sections: @escaping () -> ([FWMenuSection])) where Label == Text {
        self.init(title: title, image: nil, imageSystemName: nil, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(imageSystemName: String, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sections: @escaping () -> ([FWMenuSection])) where Label == Text {
        self.init(title: nil, image: nil, imageSystemName: imageSystemName, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(image: Image, initialMenuTitle: FWMenuItem.MenuTitle? = nil, sections: @escaping () -> ([FWMenuSection])) where Label == Text {
        self.init(title: nil, image: image, imageSystemName: nil, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    
    // MARK: - Initialise with a single FWMenuSection
    
    public init(label: Label, initialMenuTitle: FWMenuItem.MenuTitle? = nil, items: @escaping () -> (FWMenuSection)) {
        let sections =  { () -> [FWMenuSection] in
            [items()]
        }
        self.init(label: label, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(title: String, imageSystemName: String, initialMenuTitle: FWMenuItem.MenuTitle? = nil, items: @escaping () -> (FWMenuSection)) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            [items()]
        }
        self.init(title: title, imageSystemName: imageSystemName, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(title: String, image: Image, initialMenuTitle: FWMenuItem.MenuTitle? = nil, items: @escaping () -> (FWMenuSection)) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            [items()]
        }
        self.init(title: title, image: image, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(title: String, initialMenuTitle: FWMenuItem.MenuTitle? = nil, items: @escaping () -> (FWMenuSection)) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            [items()]
        }
        self.init(title: title, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(imageSystemName: String, initialMenuTitle: FWMenuItem.MenuTitle? = nil, items: @escaping () -> (FWMenuSection)) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            [items()]
        }
        self.init(imageSystemName: imageSystemName, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    public init(image: Image, initialMenuTitle: FWMenuItem.MenuTitle? = nil, items: @escaping () -> (FWMenuSection)) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            [items()]
        }
        self.init(image: image, initialMenuTitle: initialMenuTitle, sections: sections)
    }
    
    
    // MARK: - Initialise with a FWMenuItem
    
    public init(label: Label, menu: @escaping () -> FWMenuItem) {
        let sections =  { () -> [FWMenuSection] in
            menu().menuSections
        }
        self.init(label: label, sections: sections)
    }
    
    public init(title: String, imageSystemName: String, menu: @escaping () -> FWMenuItem) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            menu().menuSections
        }
        self.init(title: title, imageSystemName: imageSystemName, initialMenuTitle: menu().menuTitle, sections: sections)
    }
    
    public init(title: String, image: Image, menu: @escaping () -> FWMenuItem) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            menu().menuSections
        }
        self.init(title: title, image: image, initialMenuTitle: menu().menuTitle, sections: sections)
    }
    
    public init(title: String, menu: @escaping () -> FWMenuItem) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            menu().menuSections
        }
        self.init(title: title, initialMenuTitle: menu().menuTitle, sections: sections)
    }
    
    public init(imageSystemName: String, menu: @escaping () -> FWMenuItem) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            menu().menuSections
        }
        self.init(imageSystemName: imageSystemName, initialMenuTitle: menu().menuTitle, sections: sections)
    }
    
    public init(image: Image, menu: @escaping () -> FWMenuItem) where Label == Text {
        let sections =  { () -> [FWMenuSection] in
            menu().menuSections
        }
        self.init(image: image, initialMenuTitle: menu().menuTitle, sections: sections)
    }
    
    
    // MARK: - Body
    
    public var body: some View {
        
        if !content().isEmpty || !(hidePolicy == .hide) {
            GeometryReader { geometry in
                Button(
                    action: {
                        let frame = geometry.frame(in: .named(MenuCoordinateSpaceModifier.menuCoordinateSpaceName))
                        present(with: frame)
                    }, label: {
                        buttonLabel()
                    }
                )
                .frame(width: geometry.frame(in: .local).width, height: geometry.frame(in: .local).height)
                .opacity(content().isEmpty ? hidePolicy.opacity : 1)
                
                DoIf($isPresented) {
                    let frame = geometry.frame(in: .named(MenuCoordinateSpaceModifier.menuCoordinateSpaceName))
                    present(with: frame)
                }
            }
            .fixedSize()
        }
    }
    
    /// Binds to an isPresented Bool so the menu can be presented programmatically
    /// - Parameter isPresented: a binding to a Bool value
    public func present(isPresented: Binding<Bool>) -> Self {
        var copy = self
        copy._isPresented = isPresented
        return copy
    }
    
    
    // MARK: - Private
    
    private func present(with frame: CGRect) {
        MenuPresenter.present(parent: self, with: frame)
    }
    
    @ViewBuilder
    private func buttonLabel() -> some View {
        
        if let label = label {
            label
        } else {
            
            SwiftUI.Label(
                title: {
                    if let title = title {
                        Text(title)
                            .font(font)
                            .foregroundColor(accentColor ?? Color(.label))
                    }
                },
                icon: {
                    
                    if let imageName = imageName {
                        Image(systemName: imageName)
                            .font(font)
                            .accentColor(accentColor ?? Color(.label))
                    } else {
                        image
                            .font(font)
                            .accentColor(accentColor ?? Color(.label))
                    }
                }
            )
        }
    }
}
