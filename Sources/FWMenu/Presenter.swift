//
//  Presenter.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI


class Presenter {
    
    private static var window: UIWindow?
    private static var viewController: UIViewController?
    
    
    static func present(content: [[FWMenuItem]], with buttonFrame: CGRect) {
        
        guard let appWindow = UIApplication.window else {
            return
        }
        guard window == nil else {
            return
        }
        
        UIApplication.endEditing()
        
        if let windowScene = appWindow.windowScene {
            
            let newWindow = UIWindow(windowScene: windowScene)
            
            let viewController = WindowViewController()
            viewController.menuContent = content
            viewController.menuButtonFrame = buttonFrame
            viewController.finished = dismiss
            viewController.view.backgroundColor = .clear
            
            let tapGesture: UITapGestureRecognizer = .gestureRecognizer { _ in
                dismiss()
            }
            
            viewController.view.addGestureRecognizer(tapGesture)
            
            newWindow.rootViewController = viewController
            
            self.viewController = viewController
            
            window = newWindow
            window?.alpha = 0
            window?.makeKeyAndVisible()
            
            UIView.animate(withDuration: 0.3) {
                window?.alpha = 1
                viewController.viewWillAppear(true)
            }
        }
    }
    
    static func dismiss() {
        
        guard window != nil else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            window?.alpha = 0
            viewController?.view.alpha = 0
        } completion: { _ in
            window = nil
            viewController = nil
        }
    }
}


class WindowViewController: UIViewController {
    
    var menuContent: [[FWMenuItem]]!
    var menuButtonFrame: CGRect!
    var finished: (() -> ())!
    
    private var currentMenuViewController: MenuViewController?
    private var isSetup = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !isSetup else {
            return
        }
        
        isSetup = true
        
        let tidiedContent = menuContent.compactMap { tidyMenuContent($0) }
        guard !tidiedContent.isEmpty else {
            finished()
            return
        }
        
        currentMenuViewController = showMenu(tidiedContent)
    }
    
    private func showSubMenu(from menuItem: FWMenuItem, position: CGPoint) {
        
        let menuItems = [menuItem.submenus].compactMap { $0 } // TODO: - implement sections here as well
        
        UIView.animate(withDuration: 0.2) {
            self.currentMenuViewController?.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.currentMenuViewController?.view.alpha = 0
        }
        
        currentMenuViewController = showMenu(menuItems, position: position)
    }
    
    private func showMenu(_ content: [[FWMenuItem]], position: CGPoint? = nil) -> MenuViewController {
        
        let menuViewController = UIStoryboard(name: "MenuViewController", bundle: .module).instantiateInitialViewController() as! MenuViewController
        menuViewController.containingView = view
        menuViewController.menuContent = content
        menuViewController.finished = finished
        menuViewController.showSubmenu = { [weak self] menuItem, position in
            self?.showSubMenu(from: menuItem, position: position)
        }
        
        let menuSize = menuViewController.menuSize
        
        let screenSize = UIScreen.main.bounds.size
        let menuPadding: CGFloat = 20
        let menuOrigin = position ?? menuButtonFrame.origin
        let menuButtonSize = menuButtonFrame.size
        
        var x = min(max(menuOrigin.x - menuSize.width / 2, menuPadding), screenSize.width - menuSize.width - menuPadding)
        let y: CGFloat
        let menuHeight: CGFloat
        
        let topSpace = menuOrigin.y
        let bottomSpace = screenSize.height - (menuOrigin.y + menuButtonSize.height)
        if topSpace < menuSize.height + menuPadding * 2 && bottomSpace < menuSize.height + menuPadding * 2 {
            if menuSize.width < menuButtonFrame.origin.x - menuPadding * 2 { // fit it to the left
                menuHeight = min(menuSize.height, screenSize.height - menuPadding * 2)
                x = menuButtonFrame.origin.x - menuSize.width - menuPadding
                y = max(menuPadding, menuButtonFrame.origin.y - menuSize.height - menuPadding)
            } else if menuSize.width < screenSize.width - (menuButtonFrame.origin.x + menuButtonSize.width - menuPadding * 2) { // fit it to the right
                menuHeight = min(menuSize.height, screenSize.height - menuPadding * 2)
                x = menuButtonFrame.origin.x + menuButtonSize.width + menuPadding
                y = max(menuPadding, menuButtonFrame.origin.y - menuSize.height - menuPadding)
            } else if topSpace > bottomSpace { // goes above
                menuHeight = min(menuSize.height, menuOrigin.y - menuPadding * 2)
                y = menuOrigin.y - menuHeight - menuPadding
            } else { // goes below
                menuHeight = min(menuSize.height, bottomSpace - menuPadding * 2)
                y = menuOrigin.y + menuButtonSize.height + menuPadding
            }
        } else if topSpace < menuSize.height + menuPadding * 2 { // goes below
            menuHeight = min(menuSize.height, bottomSpace - menuPadding)
            y = menuOrigin.y + menuButtonSize.height + menuPadding
        } else if bottomSpace < menuSize.height + menuPadding * 2 { // goes above
            menuHeight = min(menuSize.height, menuOrigin.y - menuPadding * 2)
            y = menuOrigin.y - menuHeight - menuPadding
        } else if topSpace < screenSize.height / 2 { // goes below
            menuHeight = menuSize.height
            y = menuOrigin.y + menuButtonSize.height + menuPadding
        } else { // goes above
            menuHeight = menuSize.height
            y = menuOrigin.y - menuSize.height - menuPadding
        }
        
        menuViewController.view.widthAnchor.constraint(equalToConstant: menuSize.width).isActive = true
        menuViewController.view.heightAnchor.constraint(equalToConstant: menuHeight).isActive = true
        
        menuViewController.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        menuViewController.view.alpha = 0
        
        addChild(menuViewController)
        view.addSubview(menuViewController.view)
        
        let xConstraint = menuViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: menuOrigin.x)
        let yConstraint = menuViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: menuOrigin.y)
        xConstraint.isActive = true
        yConstraint.isActive = true
        
        menuViewController.didMove(toParent: self)
        
        view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            xConstraint.constant = x
            yConstraint.constant = y
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: .curveEaseIn) {
                menuViewController.view.transform = .identity
                menuViewController.view.alpha = 1
                self.view.layoutIfNeeded()
            } completion: { _ in
                menuViewController.setScrollingEnabled()
            }
        }
        
        return menuViewController
    }
    
    private func tidyMenuContent(_ content: [FWMenuItem]?) -> [FWMenuItem]? {
        
        let tidied: [FWMenuItem]? = content?.compactMap {
            if !$0.hasSubmenus {
                return $0
            }
            if let menuItems = tidyMenuContent($0.submenus), !menuItems.isEmpty {
                let menuItem = FWMenuItem(name: $0.name, style: $0.style, submenus: menuItems)
                return menuItem
            }
            return nil
        }
        
        if tidied?.isEmpty == false {
            return tidied
        }
        
        return nil
    }
}
