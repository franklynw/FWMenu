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
    
    public let content: () -> ([[FWMenuItem]])
    
    public var menuType: FWMenuType = .standard // TODO: - FWMenuType.settings is somewhat fragile, & will probably crash if the client code alters the structure of the menus after an item is selected
    public var contentBackgroundColor: Color?
    public var contentAccentColor: Color?
    public var font: Font?
    
    var accentColor: Color?
    var hidePolicy: HidePolicy = .alwaysShow
    
    private let label: Label?
    private let text: Text?
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
    
    
    public init(label: Label, sections: @escaping () -> ([[FWMenuItem]])) {
        self.label = label
        content = { () -> [[FWMenuItem]] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        text = nil
        image = nil
        title = nil
        imageName = nil
    }
    
    public init(title: String, imageSystemName: String, sections: @escaping () -> ([[FWMenuItem]])) where Label == SwiftUI.Label<Text, AnyView> {
        self.title = title
        self.imageName = imageSystemName
        content = { () -> [[FWMenuItem]] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        label = nil
        text = nil
        image = nil
    }
    
    public init(title: String, image: Image, sections: @escaping () -> ([[FWMenuItem]])) where Label == SwiftUI.Label<Text, AnyView> {
        self.title = title
        self.image = image
        content = { () -> [[FWMenuItem]] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        label = nil
        text = nil
        imageName = nil
    }
    
    public init(title: String, sections: @escaping () -> ([[FWMenuItem]])) where Label == Text {
        self.title = title
        content = { () -> [[FWMenuItem]] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        label = nil
        text = nil
        image = nil
        imageName = nil
    }
    
    public init(imageSystemName: String, sections: @escaping () -> ([[FWMenuItem]])) where Label == AnyView {
        self.imageName = imageSystemName
        content = { () -> [[FWMenuItem]] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        title = nil
        label = nil
        text = nil
        image = nil
    }
    
    public init(image: Image, sections: @escaping () -> ([[FWMenuItem]])) where Label == AnyView {
        self.image = image
        content = { () -> [[FWMenuItem]] in
            sections().compactMap { ContentTidier.tidyMenuContent($0) }
        }
        title = nil
        label = nil
        text = nil
        imageName = nil
    }
    
    public init(label: Label, items: @escaping () -> ([FWMenuItem])) {
        let sections =  { () -> [[FWMenuItem]] in
            [items()]
        }
        self.init(label: label, sections: sections)
    }
    
    public init(title: String, imageSystemName: String, items: @escaping () -> ([FWMenuItem])) where Label == SwiftUI.Label<Text, AnyView> {
        let sections =  { () -> [[FWMenuItem]] in
            [items()]
        }
        self.init(title: title, imageSystemName: imageSystemName, sections: sections)
    }
    
    public init(title: String, image: Image, items: @escaping () -> ([FWMenuItem])) where Label == SwiftUI.Label<Text, AnyView> {
        let sections =  { () -> [[FWMenuItem]] in
            [items()]
        }
        self.init(title: title, image: image, sections: sections)
    }
    
    public init(title: String, items: @escaping () -> ([FWMenuItem])) where Label == Text {
        let sections =  { () -> [[FWMenuItem]] in
            [items()]
        }
        self.init(title: title, sections: sections)
    }
    
    public init(imageSystemName: String, items: @escaping () -> ([FWMenuItem])) where Label == AnyView {
        let sections =  { () -> [[FWMenuItem]] in
            [items()]
        }
        self.init(imageSystemName: imageSystemName, sections: sections)
    }
    
    public init(image: Image, items: @escaping () -> ([FWMenuItem])) where Label == AnyView {
        let sections =  { () -> [[FWMenuItem]] in
            [items()]
        }
        self.init(image: image, sections: sections)
    }
    
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
            }
            .fixedSize()
        }
    }
    
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
