//
//  ContentTidier.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import Foundation


struct ContentTidier {
    
    static func tidyMenuContent(_ section: FWMenuSection) -> FWMenuSection? {
        
        let tidied: [FWMenuItem]? = section.menuItems.compactMap {
            
            if !$0.hasSubmenus {
                return $0
            }
            
            let menuSections = $0.menuSections.compactMap({ tidyMenuContent($0) })
            
            if !menuSections.isEmpty {
                let menuItem = FWMenuItem.submenu(name: $0.name, style: $0.style, menuSections: menuSections)
                return menuItem
            }
            
            return nil
        }
        
        if let tidied = tidied, !tidied.isEmpty {
            return FWMenuSection(tidied)
        }
        
        return nil
    }
}
