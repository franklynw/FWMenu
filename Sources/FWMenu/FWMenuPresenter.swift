//
//  FWMenuPresenter.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


public struct FWMenuPresenter: View, FWMenuPresenting {
    
    @Binding private var isPresented: Bool
    
    public let content: () -> ([[FWMenuItem]])
    
    public var contentBackgroundColor: Color?
    public var contentAccentColor: Color?
    public var font: Font?

    private let sourceRect: CGRect

    
    public init(isPresented: Binding<Bool>, menuSections: @escaping () -> ([[FWMenuItem]]), sourceRect: CGRect) {
        _isPresented = isPresented
        content = menuSections
        self.sourceRect = sourceRect
    }
    
    public init(isPresented: Binding<Bool>, menuItems: @escaping () -> ([FWMenuItem]), sourceRect: CGRect) {
        _isPresented = isPresented
        content = { () -> [[FWMenuItem]] in
            return [menuItems()]
        }
        self.sourceRect = sourceRect
    }
    
    
    public var body: some View {
        
        DoIf($isPresented) {
            MenuPresenter.present(parent: self, with: sourceRect)
            isPresented = false
        }
    }
}
