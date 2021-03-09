import XCTest
@testable import FWMenu


final class FWMenuTests: XCTestCase {
    
    func testThatMenuBasicContentIsTidiedCorrectly() {
        
        let windowViewController = WindowViewController()
        
        // given content with populated sections
        
        let content: [[FWMenuItem]] = [
            [
                FWMenuItem(name: "A", action: {}),
                FWMenuItem(name: "B", action: {}),
                FWMenuItem(name: "C", action: {})
            ],
            [
                FWMenuItem(name: "D", action: {}),
                FWMenuItem(name: "E", action: {}),
                FWMenuItem(name: "F", action: {})
            ]
        ]
        
        let tidiedContent = content.compactMap { windowViewController.tidyMenuContent($0) }
        
        // then the tidied version should keep all the populated sections
        
        XCTAssertEqual(content.count, tidiedContent.count)
        
        zip(content, tidiedContent).forEach {
            XCTAssertEqual($0.0.count, $0.1.count)
        }
    }
    
    func testThatMenuContentWithEmptySectionsIsTidiedCorrectly() {
        
        let windowViewController = WindowViewController()
        
        // given content with some populated and some empty sections
        
        let content: [[FWMenuItem]] = [
            [
                FWMenuItem(name: "A", action: {}),
                FWMenuItem(name: "B", action: {}),
                FWMenuItem(name: "C", action: {})
            ],
            [
                FWMenuItem(name: "D", action: {}),
                FWMenuItem(name: "E", action: {}),
                FWMenuItem(name: "F", action: {})
            ],
            []
        ]
        
        let tidiedContent = content.compactMap { windowViewController.tidyMenuContent($0) }
        
        // then the tidied version should keep all the populated sections and empty sections should be filtered out
        
        XCTAssertNotEqual(content.count, tidiedContent.count)
        XCTAssertEqual(tidiedContent.count, 2)
    }
    
    func testThatMenuContentWithMenuItemSubmenusIsTidiedCorrectly() {
        
        let windowViewController = WindowViewController()
        
        // given content with populated sections & sub-sections
        
        let content: [[FWMenuItem]] = [
            [
                FWMenuItem(name: "A", submenuItems: [
                    FWMenuItem(name: "D", action: {}),
                    FWMenuItem(name: "E", action: {}),
                    FWMenuItem(name: "F", action: {})
                ])
            ]
        ]
        
        let tidiedContent = content.compactMap { windowViewController.tidyMenuContent($0) }
        
        // then the tidied version should keep all the populated sub-sections
        
        XCTAssertEqual(content.count, tidiedContent.count)
        
        let section = tidiedContent[0]
        
        XCTAssertEqual(section.count, 1)
        
        let subSection = section[0].submenuSections?.first
        
        XCTAssertEqual(subSection?.count, 3)
    }
    
    func testThatMenuContentWithEmptyMenuItemSubmenusIsTidiedCorrectly() {
        
        let windowViewController = WindowViewController()
        
        // given content with some populated sections & sub-sections and some empty sections & sub-sections
        
        let content: [[FWMenuItem]] = [
            [
                FWMenuItem(name: "A", submenuItems: [])
            ],
            [
                FWMenuItem(name: "A", submenuItems: [
                    FWMenuItem(name: "D", action: {}),
                    FWMenuItem(name: "E", action: {}),
                    FWMenuItem(name: "A", submenuItems: [])
                ])
            ],
            []
        ]
        
        let tidiedContent = content.compactMap { windowViewController.tidyMenuContent($0) }
        
        // then the tidied version should keep all the populated sub-sections and empty sections should be filtered out
        
        XCTAssertNotEqual(content.count, tidiedContent.count)
        XCTAssertEqual(tidiedContent.count, 1)
        
        let section = tidiedContent[0]
        
        XCTAssertEqual(section.count, 1)
        
        let subSection = section[0].submenuSections?.first
        
        XCTAssertEqual(subSection?.count, 2)
    }
}
