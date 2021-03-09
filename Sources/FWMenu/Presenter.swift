//
//  Presenter.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI


class Presenter {
    
    private static var window: UIWindow?
    private static var viewController: WindowViewController?
    
    
    static func present<Label: View>(parent: FWMenu<Label>, with buttonFrame: CGRect) {
        
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
            viewController.menuContent = parent.content
            viewController.contentBackgroundColor = parent.contentBackgroundColor
            viewController.accentColor = parent.contentAccentColor
            viewController.font = parent.font
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
        
        viewController?.dismissMenu() { _ in
            
            UIView.animate(withDuration: 0.3) {
                window?.alpha = 0
                viewController?.view.alpha = 0
            } completion: { _ in
                window = nil
                viewController = nil
            }
        }
    }
}


class WindowViewController: UIViewController {
    
    var menuContent: [[FWMenuItem]]!
    var menuButtonFrame: CGRect!
    var contentBackgroundColor: Color?
    var accentColor: Color?
    var font: Font?
    var finished: (() -> ())!
    var dismiss: ((((Bool) -> ())?) -> ())?
    var replace: ((((Bool) -> ())?) -> ())?
    
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
    
    func dismissMenu(completion: ((Bool) -> ())? = nil) {
        dismiss?(completion)
    }
    
    private func showSubMenu(from menuItem: FWMenuItem, position: CGPoint) {
        
        guard let submenuSections = menuItem.submenuSections else {
            return
        }
        
        let menuItems: [[FWMenuItem]] = submenuSections.map { submenu in
            let submenuItems = submenu.compactMap { $0 }
            return submenuItems
        }
        
        replace? { [weak self] _ in
            self?.currentMenuViewController = self?.showMenu(menuItems, position: position)
        }
    }
    
    private func showMenu(_ content: [[FWMenuItem]], position: CGPoint? = nil) -> MenuViewController {
        
        let menuViewController = UIStoryboard(name: "MenuViewController", bundle: .module).instantiateInitialViewController() as! MenuViewController
        
        menuViewController.containingView = view
        menuViewController.menuContent = content
        menuViewController.contentBackgroundColor = contentBackgroundColor
        menuViewController.accentColor = accentColor
        menuViewController.font = font
        menuViewController.finished = finished
        menuViewController.showSubmenu = { [weak self] menuItem, position in
            self?.showSubMenu(from: menuItem, position: position)
        }
        
        let menuSize = menuViewController.menuSize
        let screenSize = UIScreen.main.bounds.size
        let menuPadding: CGFloat = 8
        
        let availableTopSpace = menuButtonFrame.minY - menuPadding * 2
        let availableBottomSpace = screenSize.height - menuButtonFrame.maxY - menuPadding * 2
        let availableLeftSpace = menuButtonFrame.minX - menuPadding * 2
        let availableRightSpace = screenSize.width - menuButtonFrame.maxX - menuPadding * 2
        
        let x, y: CGFloat
        let height: CGFloat
        
        if menuSize.height <= availableTopSpace, availableTopSpace >= availableBottomSpace {
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = menuButtonFrame.minY - menuSize.height - menuPadding
            height = menuSize.height
        } else if menuSize.height <= availableBottomSpace, availableBottomSpace > availableTopSpace {
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = menuButtonFrame.maxY + menuPadding
            height = menuSize.height
        } else if menuSize.width <= availableLeftSpace, availableLeftSpace >= availableRightSpace {
            x = menuButtonFrame.minX - menuSize.width - menuPadding
            y = min(screenSize.height - menuSize.height - menuPadding, menuButtonFrame.minY)
            height = min(menuSize.height, screenSize.height - menuPadding * 2)
        } else if menuSize.width <= availableRightSpace, availableRightSpace > availableLeftSpace {
            x = menuButtonFrame.maxX + menuPadding
            y = min(screenSize.height - menuSize.height - menuPadding, menuButtonFrame.minY)
            height = min(menuSize.height, screenSize.height - menuPadding * 2)
        } else if availableTopSpace > availableBottomSpace {
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = menuButtonFrame.minY - menuSize.height - menuPadding
            height = availableTopSpace
        } else {
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = menuButtonFrame.maxY + menuPadding
            height = availableBottomSpace
        }
        
        menuViewController.view.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: menuSize.width, height: height))
        
        let scale = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translate: CGAffineTransform
        if let position = position {
            translate = CGAffineTransform(translationX: position.x - (x + menuSize.width / 2), y: position.y - (y + height / 2))
        } else {
            translate = CGAffineTransform(translationX: menuButtonFrame.midX - (x + menuSize.width / 2), y: menuButtonFrame.midY - (y + height / 2))
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
            
            let viewController = self?.currentMenuViewController
            
            let buttonX = self?.menuButtonFrame.midX ?? 0
            let buttonY = self?.menuButtonFrame.midY ?? 0
            let translate = CGAffineTransform(translationX: buttonX - (x + menuSize.width / 2), y: buttonY - (y + height / 2))
            let transform = scale.concatenating(translate)
            
            UIView.animate(withDuration: 0.15) {
                viewController?.view.alpha = 0
            }
            UIView.animate(withDuration: 0.3, animations: {
                viewController?.view.transform = transform
            }, completion: { finished in
                self?.removeViewController(viewController)
                completion?(finished)
            })
        }
        
        replace = { [weak self] completion in
            
            let viewController = self?.currentMenuViewController
            
            UIView.animate(withDuration: 0.15, animations: {
                viewController?.view.alpha = 0
            }, completion: { finished in
                completion?(finished)
            })
            UIView.animate(withDuration: 0.3, animations: {
                viewController?.view.alpha = 0
                viewController?.view.transform = scale
            }, completion: { finished in
                self?.removeViewController(viewController)
            })
        }
        
        return menuViewController
    }
    
    private func removeViewController(_ viewController: UIViewController?) {
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
    }
    
    func tidyMenuContent(_ section: [FWMenuItem]) -> [FWMenuItem]? {
        
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
