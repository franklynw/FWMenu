//
//  SizingView.swift
//  
//
//  Created by Franklyn Weber on 14/03/2021.
//

import SwiftUI


struct SizingView<Content: View>: View {
    
    let content: Content
    let updateSize: ((_ size: CGSize) -> Void)
    
    init(@ViewBuilder content: () -> Content, updateSize: @escaping (_ size: CGSize) -> Void) {
        self.content = content()
        self.updateSize = updateSize
    }
    
    var body: some View {
        
        content.background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            updateSize(preferences)
        }
    }
}


struct SizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
