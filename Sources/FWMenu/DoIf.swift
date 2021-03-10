//
//  DoIf.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


struct DoIf: View {
    
    private var binding: Binding<Bool>
    private let action: () -> ()
    private let otherAction: (() -> ())?
    
    
    init(_ isTrue: Binding<Bool>, _ action: @escaping () -> (), else otherAction: (() -> ())? = nil) {
        binding = isTrue
        self.action = action
        self.otherAction = otherAction
    }
    
    var body: some View {
        
        return If(binding) { () -> EmptyView in
            self.action()
            return EmptyView()
        } else: { () -> EmptyView in
            self.otherAction?()
            return EmptyView()
        }
    }
}


struct If: View {
    
    private let viewProvider: () -> AnyView
    
    init<V: View, O: View>(_ isTrue: Binding<Bool>, @ViewBuilder _ viewProvider: @escaping () -> V, @ViewBuilder else otherViewProvider: @escaping () -> O) {
        self.viewProvider = {
            isTrue.wrappedValue ? AnyView(viewProvider()) : AnyView(otherViewProvider())
        }
    }
    
    var body: some View {
        return viewProvider()
    }
}
