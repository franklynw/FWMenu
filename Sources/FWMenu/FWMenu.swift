import SwiftUI


public struct FWMenu<Label: View>: View {
    
    let content: [[FWMenuItem]]
    
    private let label: Label?
    private let text: Text?
    private let image: Image?
    private let title: String?
    private let imageName: String?
    
    var contentBackgroundColor: Color?
    var contentAccentColor: Color?
    var accentColor: Color?
    var font: Font?
    
    
    public init(label: Label, sections: [[FWMenuItem]]) {
        self.label = label
        content = sections.compactMap { ContentTidier.tidyMenuContent($0) }
        text = nil
        image = nil
        title = nil
        imageName = nil
    }
    
    public init(title: String, imageSystemName: String, sections: [[FWMenuItem]]) where Label == SwiftUI.Label<Text, AnyView> {
        self.title = title
        self.imageName = imageSystemName
        content = sections.compactMap { ContentTidier.tidyMenuContent($0) }
        label = nil
        text = nil
        image = nil
    }
    
    public init(title: String, image: Image, sections: [[FWMenuItem]]) where Label == SwiftUI.Label<Text, AnyView> {
        self.title = title
        self.image = image
        content = sections.compactMap { ContentTidier.tidyMenuContent($0) }
        label = nil
        text = nil
        imageName = nil
    }
    
    public init(title: String, sections: [[FWMenuItem]]) where Label == Text {
        self.title = title
        content = sections.compactMap { ContentTidier.tidyMenuContent($0) }
        label = nil
        text = nil
        image = nil
        imageName = nil
    }
    
    public init(imageSystemName: String, sections: [[FWMenuItem]]) where Label == AnyView {
        self.imageName = imageSystemName
        content = sections.compactMap { ContentTidier.tidyMenuContent($0) }
        title = nil
        label = nil
        text = nil
        image = nil
    }
    
    public init(image: Image, sections: [[FWMenuItem]]) where Label == AnyView {
        self.image = image
        content = sections.compactMap { ContentTidier.tidyMenuContent($0) }
        title = nil
        label = nil
        text = nil
        imageName = nil
    }
    
    public init(label: Label, items: [FWMenuItem]) {
        self.init(label: label, sections: [items])
    }
    
    public init(title: String, imageSystemName: String, items: [FWMenuItem]) where Label == SwiftUI.Label<Text, AnyView> {
        self.init(title: title, imageSystemName: imageSystemName, sections: [items])
    }
    
    public init(title: String, image: Image, items: [FWMenuItem]) where Label == SwiftUI.Label<Text, AnyView> {
        self.init(title: title, image: image, sections: [items])
    }
    
    public init(title: String, items: [FWMenuItem]) where Label == Text {
        self.init(title: title, sections: [items])
    }
    
    public init(imageSystemName: String, items: [FWMenuItem]) where Label == AnyView {
        self.init(imageSystemName: imageSystemName, sections: [items])
    }
    
    public init(image: Image, items: [FWMenuItem]) where Label == AnyView {
        self.init(image: image, sections: [items])
    }
    
    public var body: some View {
        
        if !content.isEmpty {
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
            }
            .fixedSize()
        }
    }
    
    private func present(with frame: CGRect) {
        Presenter.present(parent: self, with: frame)
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


extension FWMenu {
    
    public func contentBackgroundColor(_ contentBackgroundColor: Color) -> Self {
        var copy = self
        copy.contentBackgroundColor = contentBackgroundColor
        return copy
    }
    
    public func contentAccentColor(_ contentAccentColor: Color) -> Self {
        var copy = self
        copy.contentAccentColor = contentAccentColor
        return copy
    }
    
    public func accentColor(_ accentColor: Color) -> Self {
        var copy = self
        copy.accentColor = accentColor
        return copy
    }
    
    public func font(_ font: Font) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
}
