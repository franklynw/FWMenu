//
//  ContentTidier.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import Foundation


struct ContentTidier {
    
    static func tidyMenuContent(_ section: [FWMenuItem]) -> [FWMenuItem]? {
        
        let tidied: [FWMenuItem]? = section.compactMap {
            if !$0.hasSubmenus {
                return $0
            }
            if let menuSections = $0.submenuSections?.compactMap({ tidyMenuContent($0) }), !menuSections.isEmpty {
                let menuItem = FWMenuItem(name: $0.name, style: $0.style, submenuSections: menuSections)
                return menuItem
            }
            return nil
        }
        
        if let tidied = tidied, !tidied.isEmpty {
            return tidied
        }
        
        return nil
    }
}
