import SwiftUI


public struct FWMenu<Label: View>: View {
    
    private let label: Label
    private let content: [[FWMenuItem]]
    
    
    public init(label: Label, content: [[FWMenuItem]]) {
        self.label = label
        self.content = content
    }
    
    public init(title: String, image: Image, content: [[FWMenuItem]]) where Label == SwiftUI.Label<Text, Image> {
        
        label = SwiftUI.Label(
            title: { Text(title) },
            icon: { image }
        )
        
        self.content = content
    }
    
    public init(title: String, content: [[FWMenuItem]]) where Label == Text {
        label = Text(title)
        self.content = content
    }
    
    public init(image: Image, content: [[FWMenuItem]]) where Label == Image {
        self.content = content
        label = image
    }
    
    public var body: some View {
         
        GeometryReader { geometry in
            Button(
                action: {
                    let frame = geometry.frame(in: .named(MenuCoordinateSpaceModifier.menuCoordinateSpaceName))
                    present(with: frame)
                }, label: {
                    label
                }
            )
            .frame(width: geometry.frame(in: .local).width, height: geometry.frame(in: .local).height)
        }
        .fixedSize()
    }
    
    private func present(with frame: CGRect) {
        Presenter.present(content: content, with: frame)
    }
}
