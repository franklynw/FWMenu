import SwiftUI


public struct FWMenu<Label: View>: View {
    
    private let content: [[FWMenuItem]]
    
    private let label: Label?
    private let text: Text?
    private let image: Image?
    private let title: String?
    private let imageName: String?
    
    private var accentColor: Color?
    private var font: Font?
    
    
    public init(label: Label, content: [[FWMenuItem]]) {
        self.label = label
        self.content = content
        text = nil
        image = nil
        title = nil
        imageName = nil
    }
    
    public init(title: String, imageSystemName: String, content: [[FWMenuItem]]) where Label == SwiftUI.Label<Text, AnyView> {
        self.title = title
        self.imageName = imageSystemName
        self.content = content
        label = nil
        text = nil
        image = nil
    }
    
    public init(title: String, image: Image, content: [[FWMenuItem]]) where Label == SwiftUI.Label<Text, AnyView> {
        self.title = title
        self.image = image
        self.content = content
        label = nil
        text = nil
        imageName = nil
    }
    
    public init(title: String, content: [[FWMenuItem]]) where Label == Text {
        self.title = title
        self.content = content
        label = nil
        text = nil
        image = nil
        imageName = nil
    }
    
    public init(imageSystemName: String, content: [[FWMenuItem]]) where Label == AnyView {
        self.imageName = imageSystemName
        self.content = content
        title = nil
        label = nil
        text = nil
        image = nil
    }
    
    public init(image: Image, content: [[FWMenuItem]]) where Label == AnyView {
        self.content = content
        self.image = image
        title = nil
        label = nil
        text = nil
        imageName = nil
    }
    
    public var body: some View {
         
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
    
    private func present(with frame: CGRect) {
        Presenter.present(content: content, with: frame)
    }
    
    @ViewBuilder
    private func buttonLabel() -> some View {
    
        if let label = label {
            label
        } else if let title = title, let image = image {
            
            SwiftUI.Label(
                title: {
                    Text(title)
                        .font(font)
                        .foregroundColor(accentColor ?? Color(.label))
                },
                icon: {
                    image
                        .font(font)
                        .accentColor(accentColor ?? Color(.label))
                }
            )
            
        } else if let title = title, let imageName = imageName {
            
            SwiftUI.Label(
                title: {
                    Text(title)
                        .font(font)
                        .foregroundColor(accentColor ?? Color(.label))
                },
                icon: {
                    Image(systemName: imageName)
                        .font(font)
                        .accentColor(accentColor ?? Color(.label))
                }
            )
            
        } else if let title = title {
            
            Text(title)
                .font(font)
                .foregroundColor(accentColor ?? Color(.label))
            
        } else if let image = image {
            
            image
                .font(font)
                .accentColor(accentColor ?? Color(.label))
            
        } else if let imageName = imageName {
            
            Image(systemName: imageName)
                .font(font)
                .accentColor(accentColor ?? Color(.label))
        }
    }
}


extension FWMenu {
    
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
