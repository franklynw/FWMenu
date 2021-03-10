//
//  MenuPresenter.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI


public class MenuPresenter {
    
    private static var window: UIWindow?
    private static var viewController: WindowViewController?
    
    
    public static func presentFromNavBar(parent: FWMenuPresenting, withRelativeX relativeX: CGFloat) {
        
        let screenSize = UIScreen.main.bounds.size
        let notchOffset: CGFloat = UIDevice.hasNotch ? 32 : 0
        let buttonFrame = CGRect(origin: CGPoint(x: screenSize.width * relativeX, y: 40 + notchOffset), size: CGSize(width: 10, height: 10))
        
        present(parent: parent, with: buttonFrame)
    }
    
    public static func present(parent: FWMenuPresenting, with buttonFrame: CGRect) {
        
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
