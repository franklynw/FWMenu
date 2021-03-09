//
//  FWMenuPresenter.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


public struct FWMenuPresenter: View, FWMenuPresenting {
    
    @Binding private var isPresented: Bool
    
    public let content: [[FWMenuItem]]
    
    public var contentBackgroundColor: Color?
    public var contentAccentColor: Color?
    public var font: Font?

    private let sourceRect: CGRect

    
    public init(isPresented: Binding<Bool>, menuSections: [[FWMenuItem]], sourceRect: CGRect) {
        _isPresented = isPresented
        content = menuSections
        self.sourceRect = sourceRect
    }
    
    public init(isPresented: Binding<Bool>, menuItems: [FWMenuItem], sourceRect: CGRect) {
        _isPresented = isPresented
        content = [menuItems]
        self.sourceRect = sourceRect
    }
    
    
    public var body: some View {
        
        DoIf($isPresented) {
            MenuPresenter.present(parent: self, with: sourceRect)
        }
    }
}


extension FWMenuPresenter {
    
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
    
    public func font(_ font: Font) -> Self {
        var copy = self
        copy.font = font
        return copy
    }
}
