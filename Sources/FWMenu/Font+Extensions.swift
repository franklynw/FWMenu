//
//  Font+Extensions.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


extension Font {
    
    var uiStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        default:
            return .body
        }
    }
    
    func uiFont() -> UIFont {
        return UIFont.preferredFont(forTextStyle: uiStyle)
    }
}
