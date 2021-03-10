//
//  WindowViewController.swift
//  
//
//  Created by Franklyn Weber on 09/03/2021.
//

import SwiftUI


class WindowViewController: UIViewController {
    
    static let menuPadding: CGFloat = 8
    
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
        
        currentMenuViewController = showMenu(menuContent)
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
        let menuPadding = Self.menuPadding
        let topPadding = menuPadding * (UIDevice.hasNotch ? 5 : 3)
        
        let availableTopSpace = menuButtonFrame.minY - topPadding
        let availableBottomSpace = screenSize.height - menuButtonFrame.maxY - menuPadding * 2
        let availableLeftSpace = menuButtonFrame.minX - menuPadding * 2
        let availableRightSpace = screenSize.width - menuButtonFrame.maxX - menuPadding * 2
        
        let x, y: CGFloat
        let height: CGFloat
        
        // positioning priority order -
        
        if menuSize.height <= availableTopSpace, availableTopSpace >= availableBottomSpace { // above the button
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = menuButtonFrame.minY - menuSize.height - menuPadding
            height = menuSize.height
        } else if menuSize.height <= availableBottomSpace, availableBottomSpace > availableTopSpace { // below the button
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = menuButtonFrame.maxY + menuPadding * 2
            height = menuSize.height
        } else if menuSize.width <= availableLeftSpace, availableLeftSpace >= availableRightSpace { // to the left of the button
            x = menuButtonFrame.minX - menuSize.width - menuPadding
            y = max(min(screenSize.height - menuSize.height - menuPadding, menuButtonFrame.minY), topPadding)
            height = min(menuSize.height, screenSize.height - menuPadding - topPadding)
        } else if menuSize.width <= availableRightSpace, availableRightSpace > availableLeftSpace { // to the right of the button
            x = menuButtonFrame.maxX + menuPadding
            y = max(min(screenSize.height - menuSize.height - menuPadding, menuButtonFrame.minY), topPadding)
            height = min(menuSize.height, screenSize.height - menuPadding - topPadding)
        } else if availableTopSpace > availableBottomSpace { // above the button, but reduce the menu height
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = max(menuButtonFrame.minY - menuSize.height - menuPadding, topPadding)
            height = availableTopSpace
        } else { // below the button, but reduce the menu height
            x = min(max(menuButtonFrame.maxX - menuSize.width, menuPadding), screenSize.width - menuSize.width - menuPadding)
            y = menuButtonFrame.maxY + menuPadding * 2
            height = availableBottomSpace - menuPadding
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
        
        let panGestureRecognizer: UIPanGestureRecognizer = .gestureRecognizer(delegate: self) { recognizer in
            menuViewController.userPanned(recognizer)
        }
        view.addGestureRecognizer(panGestureRecognizer)
        
        return menuViewController
    }
    
    private func removeViewController(_ viewController: UIViewController?) {
        viewController?.willMove(toParent: nil)
        viewController?.view.removeFromSuperview()
        viewController?.removeFromParent()
    }
}


extension WindowViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
