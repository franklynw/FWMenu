//
//  WindowViewController.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


class WindowViewController: UIViewController {
    
    static let menuPadding: CGFloat = 8
    
    var menuContent: (() -> [FWMenuSection])!
    var menuButtonFrame: CGRect?
    var menuType: FWMenuType!
    var contentBackgroundColor: Color?
    var accentColor: Color?
    var font: Font?
    var hideMenuOnDeviceRotation = false
    var finished: (() -> ())!
    var dismiss: ((((Bool) -> ())?) -> ())?
    var replace: ((((Bool) -> ())?) -> ())?
    
    private var menuViewControllers: [MenuViewController] = []
    private var isSetup = false
    private var deviceOrientation = UIDevice.current.orientation
    private var orientationObserver: NSObjectProtocol?
    
    
    deinit {
        if let orientationObserver = orientationObserver {
            NotificationCenter.default.removeObserver(orientationObserver)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orientationObserver = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self, self.hideMenuOnDeviceRotation else {
                return
            }
            if !UIDevice.current.orientation.isAspectEqual(to: self.deviceOrientation) {
                self.deviceOrientation = UIDevice.current.orientation
                self.dismiss?(nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !isSetup else {
            return
        }
        
        isSetup = true
        
        let menuViewController = showMenu(title: menuType.menuTitle, content: menuContent(), parentMenu: nil)
        menuViewControllers.append(menuViewController)
        
        let panGestureRecognizer: UIPanGestureRecognizer = .gestureRecognizer(delegate: self) { [weak self] recognizer in
            self?.menuViewControllers.last?.userPanned(recognizer)
        }
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func dismissMenu(completion: ((Bool) -> ())? = nil) {
        dismiss? { [weak self] finished in
            self?.menuViewControllers.removeAll()
            completion?(finished)
        }
    }
}


// MARK: - Private
extension WindowViewController {
    
    private func showSubMenu(from menu: MenuViewController, menuItem: FWMenuItem, position: CGPoint) {
        
        guard let menuSections = getMenuContent(from: menuItem) else {
            return
        }
        
        if !menu.isTopMenu {
            removeTopMenu { [weak self] _ in
                self?.menuViewControllers.last?.isTopMenu = true
                self?.scaleMenus()
            }
        } else {
            replace? { [weak self] _ in
                if let menuViewController = self?.showMenu(title: menuItem.menuTitle, content: menuSections, parentMenu: menu, position: position) {
                    self?.menuViewControllers.append(menuViewController)
                }
                self?.scaleMenus()
            }
        }
    }
    
    private func dismissLevel() {
        
        var content: [FWMenuSection]? = self.menuContent()
        
        removeTopMenu { [weak self] _ in
            
            guard let self = self else {
                return
            }
            
            self.menuViewControllers.forEach { menuViewController in
                
                let selectedIndexPath = menuViewController.selectedItem
                
                func recalculateSize() {
                    
                    let menuScale = menuViewController.baseScale
                    let menuSize = CGSize(width: menuViewController.menuSize.width * menuScale, height: menuViewController.menuSize.height * menuScale)
                    if menuSize != menuViewController.view.frame.size {
                        
                        let minX = menuViewController.view.frame.minX
                        let maxX = min(minX + menuSize.width, UIScreen.main.bounds.width - Self.menuPadding)
                        let x = maxX - menuSize.width
                        let y = menuViewController.view.frame.minY
                        let height = menuViewController.view.frame.height
                        
                        UIView.animate(withDuration: 0.2) {
                            menuViewController.view.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: menuSize.width, height: height))
                        }
                    }
                }
                
                if let menuContent = content, !menuContent.isEmpty {
                    
                    menuViewController.refreshContent(menuContent)
                    recalculateSize()
                    
                    var foundContent: [FWMenuSection]?
                    if let selectedIndexPath = selectedIndexPath {
                        let sectionIndex = selectedIndexPath.section
                        let rowIndex = selectedIndexPath.row
                        if sectionIndex < menuContent.count {
                            let section = menuContent[sectionIndex].menuItems
                            if rowIndex < section.count {
                                foundContent = section[rowIndex].menuSections
                            }
                        }
                    }
                    content = foundContent
                }
            }
            
            self.menuViewControllers.last?.isTopMenu = true
            self.scaleMenus()
        }
    }
    
    private func showMenu(title: FWMenuItem.MenuTitle?, content: [FWMenuSection], parentMenu: MenuViewController?, position: CGPoint? = nil) -> MenuViewController {
        
        let menuViewController = UIStoryboard(name: "MenuViewController", bundle: .module).instantiateInitialViewController() as! MenuViewController
        
        menuViewController.containingView = view
        menuViewController.parentMenu = parentMenu
        menuViewController.menuTitle = title
        menuViewController.menuContent = content
        menuViewController.contentBackgroundColor = contentBackgroundColor
        menuViewController.accentColor = accentColor
        menuViewController.font = font
        
        menuViewController.showSubmenu = { [weak self] menu, menuItem, position in
            self?.showSubMenu(from: menu, menuItem: menuItem, position: position)
        }
        
        menuViewController.finished = { [weak self] in
            switch self?.menuType {
            case .standard:
                self?.finished()
            case .settings:
                self?.dismissLevel()
            case .none:
                break
            }
        }
        
        let menuSize = menuViewController.menuSize
        let screenSize = UIScreen.main.bounds.size
        let menuPadding = Self.menuPadding
        let topPadding = menuPadding * (UIDevice.hasNotch ? 5 : 3)
        
        let sourceRect = menuButtonFrame ?? {
            
            let x = max((screenSize.width - menuSize.width) / 2, menuPadding)
            let y = max((screenSize.height - menuSize.height) / 2, topPadding)
            
            return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: 1, height: 1))
        }()
        
        let availableTopSpace = sourceRect.minY - topPadding
        let availableBottomSpace = screenSize.height - sourceRect.maxY - menuPadding * 2
        let availableLeftSpace = sourceRect.minX - menuPadding * 2
        let availableRightSpace = screenSize.width - sourceRect.maxX - menuPadding * 2
        
        let x, y: CGFloat
        let height: CGFloat
        
        // positioning priority order -
        
        if menuSize.height <= availableTopSpace, availableTopSpace >= availableBottomSpace { // above the button
            x = min(max(sourceRect.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = sourceRect.minY - menuSize.height - menuPadding
            height = menuSize.height
        } else if menuSize.height <= availableBottomSpace, availableBottomSpace > availableTopSpace { // below the button
            x = min(max(sourceRect.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = sourceRect.maxY + menuPadding * 2
            height = menuSize.height
        } else if menuSize.width <= availableLeftSpace, availableLeftSpace >= availableRightSpace { // to the left of the button
            x = sourceRect.minX - menuSize.width - menuPadding
            y = max(min(screenSize.height - menuSize.height - menuPadding, sourceRect.minY), topPadding)
            height = min(menuSize.height, screenSize.height - menuPadding - topPadding)
        } else if menuSize.width <= availableRightSpace, availableRightSpace > availableLeftSpace { // to the right of the button
            x = sourceRect.maxX + menuPadding
            y = max(min(screenSize.height - menuSize.height - menuPadding, sourceRect.minY), topPadding)
            height = min(menuSize.height, screenSize.height - menuPadding - topPadding)
        } else if availableTopSpace > availableBottomSpace { // above the button, but reduce the menu height
            x = min(max(sourceRect.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = max(sourceRect.minY - menuSize.height - menuPadding, topPadding)
            height = availableTopSpace
        } else { // below the button, but reduce the menu height
            x = min(max(sourceRect.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = sourceRect.maxY + menuPadding * 2
            height = availableBottomSpace - menuPadding
        }
        
        menuViewController.view.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: menuSize.width, height: height))
        
        let scale = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translate: CGAffineTransform
        if let position = position {
            translate = CGAffineTransform(translationX: position.x - (x + menuSize.width / 2), y: position.y - (y + height / 2))
        } else {
            translate = CGAffineTransform(translationX: sourceRect.midX - (x + menuSize.width / 2), y: sourceRect.midY - (y + height / 2))
        }
        let transform = scale.concatenating(translate)
        
        menuViewController.view.transform = transform
        menuViewController.view.alpha = 0
        
        addChild(menuViewController)
        view.addSubview(menuViewController.view)
        menuViewController.didMove(toParent: self)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseInOut) {
            menuViewController.view.transform = .identity
            menuViewController.view.alpha = 1
        } completion: { _ in
            menuViewController.setScrollingEnabled()
        }
        
        dismiss = { [weak self] completion in
            
            let viewControllers = self?.menuViewControllers
            
            let buttonX = sourceRect.midX
            let buttonY = sourceRect.midY
            let translate = CGAffineTransform(translationX: buttonX - (x + menuSize.width / 2), y: buttonY - (y + height / 2))
            let transform = scale.concatenating(translate)
            
            UIView.animate(withDuration: 0.15) {
                viewControllers?.forEach {
                    $0.view.alpha = 0
                }
            }
            UIView.animate(withDuration: 0.3, animations: {
                viewControllers?.forEach {
                    $0.view.transform = transform
                }
            }, completion: { finished in
                viewControllers?.forEach {
                    self?.removeViewController($0)
                }
                completion?(finished)
            })
        }
        
        replace = { [weak self] completion in
            
            switch self?.menuType {
            case .settings:
                completion?(true)
                return
            case .standard:
                self?.removeTopMenu(completion: completion)
            case .none:
                return
            }
        }
        
        return menuViewController
    }
    
    private func getMenuContent(from menuItem: FWMenuItem) -> [FWMenuSection]? {
        
        guard menuItem.hasSubmenus else {
            return nil
        }
        
        let menuItems: [FWMenuSection] = menuItem.menuSections.map { submenu in
            let submenuItems = submenu.menuItems.compactMap { $0 }
            return FWMenuSection(submenuItems)
        }
        
        return menuItems
    }
    
    private func removeTopMenu(completion: ((Bool) -> ())?) {
        
        let viewController = menuViewControllers.removeLast()
        
        UIView.animate(withDuration: 0.15, animations: {
            viewController.view.alpha = 0
        }, completion: { finished in
            completion?(finished)
        })
        UIView.animate(withDuration: 0.3, animations: {
            viewController.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { finished in
            self.removeViewController(viewController)
        })
    }
    
    private func scaleMenus() {
        UIView.animate(withDuration: 0.3) {
            self.menuViewControllers.reversed().enumerated().forEach {
                $0.element.baseScale = 1 - CGFloat($0.offset) * 0.1
            }
        }
    }
    
    private func removeViewController(_ viewController: UIViewController?) {
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
    }
}


// MARK: - UIGestureRecognizerDelegate
extension WindowViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


fileprivate extension UIDeviceOrientation {
    
    func isAspectEqual(to orientation: UIDeviceOrientation) -> Bool {
        
        switch (self.isLandscape, orientation.isLandscape) {
        case (true, true), (false, false):
            return true
        default:
            return false
        }
    }
}
