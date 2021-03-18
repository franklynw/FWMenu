//
//  MenuViewController.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI
import CGExtensions


class MenuViewController: UIViewController {
    
    typealias Action = () -> ()
    
    @IBOutlet weak var blurredBackgroundImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    weak var containingView: UIView?
    weak var parentMenu: MenuViewController?
    
    var menuTitle: FWMenuItem.Title?
    var menuContent: [FWMenuSection] = []
    var contentBackgroundColor: Color?
    var accentColor: Color?
    var font: Font?
    var isTopMenu = true
    var selectedItem: IndexPath?
    var getBackgroundImage: ((MenuViewController) -> UIImage?)!
    var showSubmenu: ((MenuViewController, FWMenuItem, CGPoint) -> ())!
    var finished: ((Action?) -> ())!
    
    var baseScale: CGFloat = 1 {
        didSet {
            view.transform = CGAffineTransform(scaleX: baseScale, y: baseScale)
        }
    }
    
    private var menuHeaderView: MenuHeaderView?
    private var menuBackgroundColor: UIColor?
    private var isScrollingEnabled = true
    private var done = false
    
    private static let defaultBackgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    private static let selectedBackgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    static let sectionHeaderColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.5)
    
    private static let sectionHeaderHeight: CGFloat = 7
    private static let minMenuWidth: CGFloat = 200
    private static let dragSensitivity: CGFloat = 250 // the lower the number, the more static the user's finger needs to be for the selection to occur
    
    private var menuAccentColor: UIColor? {
        guard let accentColor = accentColor else {
            return nil
        }
        return UIColor(accentColor)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let contentBackgroundColor = contentBackgroundColor {
            menuBackgroundColor = UIColor(contentBackgroundColor).withAlphaComponent(0.9)
        } else {
            menuBackgroundColor = Self.defaultBackgroundColor
        }
        
        view.layer.cornerRadius = 15
        view.layer.shadowRadius = 50
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let menuHeaderView = menuHeaderView {
            tableView.tableHeaderView = menuHeaderView
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.blurredBackgroundImageView.image = self.getBackgroundImage(self)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        guard let menuHeaderView = menuHeaderView else {
            return
        }
        
        let menuHeaderHeight = menuHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        menuHeaderView.frame = CGRect(origin: menuHeaderView.frame.origin, size: CGSize(width: menuHeaderView.frame.width, height: menuHeaderHeight))
    }
    
    
    var menuSize: CGSize {
        
        if let menuTitle = menuTitle {
            menuHeaderView = MenuHeaderView(title: menuTitle, backgroundColor: Self.sectionHeaderColor.withAlphaComponent(0.4), menuAccentColor: menuAccentColor)
        }
        
        let screenSize = UIScreen.main.bounds.size
        let menuPadding = WindowViewController.menuPadding
        let availableWidth = screenSize.width - menuPadding * 2
        let availableHeight = screenSize.height - menuPadding * (UIDevice.hasNotch ? 6 : 3) // allow for status bar & notch
        
        let rowPadding: CGFloat = 32
        var maxWidth = CGFloat.zero
        
        let menuHeaderHeight: CGFloat
        if let menuHeaderView = menuHeaderView {
            let headerSize = menuHeaderView.size
            maxWidth = headerSize.width
            menuHeaderHeight = headerSize.height
        } else {
            menuHeaderHeight = 0
        }
        
        let totalHeight = menuHeaderHeight + menuContent.reduce(CGFloat.zero) {
            
            let section = $1
            
            let sectionHeight = section.menuItems.reduce(CGFloat.zero) {
                
                let maxTextWidth: CGFloat
                let additionalPadding: CGFloat
                if $1.iconImage == nil && !$1.hasSubmenus {
                    maxTextWidth = availableWidth - rowPadding
                    additionalPadding = rowPadding
                } else {
                    maxTextWidth = availableWidth - rowPadding - 44
                    additionalPadding = rowPadding + 44
                }
                
                let size = $1.name.boundingRect(with: CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], context: nil).size
                let height = size.height + 22.5
                
                maxWidth = max(size.width + additionalPadding, maxWidth)
                
                return $0 + height
            }
            
            return $0 + sectionHeight + Self.sectionHeaderHeight
        }
        
        let width = min(max(maxWidth, Self.minMenuWidth), availableWidth)
        let height = min(totalHeight - Self.sectionHeaderHeight, availableHeight)
        
        isScrollingEnabled = totalHeight > availableHeight
        
        return CGSize(width: width, height: height)
    }
    
    func setScrollingEnabled() {
        tableView.isScrollEnabled = isScrollingEnabled
    }
    
    func userPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard isTopMenu else {
            return
        }
        
        let touchLocation = gestureRecognizer.location(in: view)
        let indexPath = self.indexPath(forRowAtOffset: touchLocation)
        
        switch gestureRecognizer.state {
        case .began:
            guard let indexPath = indexPath else {
                if !done {
                    done = true
                    finished(nil)
                }
                return
            }
            guard !isScrollingEnabled else {
                return
            }
            selectRow(at: indexPath)
        case .changed:
            guard !isScrollingEnabled, !done else {
                selectRow(at: nil)
                return
            }
            selectRow(at: indexPath)
        case .ended:
            
            selectRow(at: nil)
            self.fullSize()
            
            guard !isScrollingEnabled, !done, let indexPath = indexPath, indexPath.row > -1, gestureRecognizer.velocity(in: tableView).magnitude < Self.dragSensitivity else {
                return
            }
                
            let cellRect = tableView.rectForRow(at: indexPath)
            let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let positionInSuperview = tableView.convert(cellPosition, to: containingView)
            
            let menuItem = menuContent[indexPath.section].menuItems[indexPath.row]
            menuItemWasTapped(menuItem, indexPath: indexPath, position: positionInSuperview)
            
        default:
            selectRow(at: nil)
            self.fullSize()
        }
        
        dropBackIfNecessary(touchLocation: gestureRecognizer.location(in: containingView))
    }
    
    func userPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        let touchLocation = gestureRecognizer.location(in: view)
        let indexPath = self.indexPath(forRowAtOffset: touchLocation)
        
        switch gestureRecognizer.state {
        case .began:
            guard let indexPath = indexPath else {
                if !done {
                    done = true
                    finished(nil)
                }
                return
            }
            selectRow(at: indexPath)
        case .ended:
            
            selectRow(at: nil)
            self.fullSize()
            
            guard let indexPath = indexPath, indexPath.row > -1 else {
                return
            }
                
            let cellRect = tableView.rectForRow(at: indexPath)
            let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let positionInSuperview = tableView.convert(cellPosition, to: containingView)
            
            let menuItem = menuContent[indexPath.section].menuItems[indexPath.row]
            menuItemWasTapped(menuItem, indexPath: indexPath, position: positionInSuperview)
            
        default:
            break
        }
    }
    
    func refreshContent(_ content: [FWMenuSection]) {
        
        menuContent = content
        done = false
        
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
}


// MARK: - Private
extension MenuViewController {
    
    private func menuItemWasTapped(_ menuItem: FWMenuItem, indexPath: IndexPath, position: CGPoint) {
        
        guard !done else {
            return
        }
        
        done = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.done = false
        }
        
        if menuItem.hasSubmenus {
            selectedItem = indexPath
            showSubmenu(self, menuItem, position)
        } else {
            finished(menuItem.action)
        }
        
        isTopMenu = false
    }
    
    private func selectRow(at indexPath: IndexPath?) {
        
        if let selectedItem = selectedItem, selectedItem != indexPath {
            if let cell = tableView.cellForRow(at: selectedItem) as? MenuRowCell {
                cell.deselect()
            }
        }
        if let indexPath = indexPath, indexPath.row > -1 {
            if let cell = tableView.cellForRow(at: indexPath) as? MenuRowCell {
                cell.select()
            }
            if indexPath != selectedItem {
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
            }
        }
        
        if indexPath?.row == -1 {
            selectedItem = nil
        } else {
            selectedItem = indexPath
        }
    }
    
    private func indexPath(forRowAtOffset touchOffset: CGPoint) -> IndexPath? {
        
        // don't know if there's a better way of finding the row for a particular y position, when there are varying row heights
        // in any case, this is super quick as it's just a binary search
        
        guard touchOffset.x > 0 && touchOffset.x < tableView.frame.width else {
            return nil
        }
        guard touchOffset.y > 0 && touchOffset.y < tableView.frame.height else {
            return nil
        }
        
        let offset = CGPoint(x: touchOffset.x, y: touchOffset.y + tableView.contentOffset.y)
        let tableHeight = tableView.contentSize.height
        let totalRows = menuContent.reduce(0) { $0 + $1.menuItems.count }
        let sectionsCount = menuContent.count
        
        guard tableHeight > 0, totalRows > 0 else {
            return nil
        }
        
        var guess = Int(offset.y / tableHeight * CGFloat(totalRows))
        var step = guess / 2
        var result: IndexPath?
        var finished = false
        
        while !finished {
            
            var indexPath: IndexPath?
            var sectionIndex = 0
            var pointer = guess
            
            while indexPath == nil && sectionIndex < sectionsCount {
                let items = menuContent[sectionIndex]
                let itemsCount = items.menuItems.count
                if pointer >= itemsCount {
                    pointer -= items.menuItems.count
                    sectionIndex += 1
                } else {
                    indexPath = IndexPath(row: pointer, section: sectionIndex)
                }
            }
            
            if let indexPath = indexPath, indexPath.row >= 0 {
                let rowRect = tableView.rectForRow(at: indexPath).inset(by: UIEdgeInsets(top: indexPath.row == 0 ? -Self.sectionHeaderHeight : 0, left: 0, bottom: 0, right: 0))
                if offset.y < rowRect.minY {
                    guess -= step
                } else if offset.y > rowRect.maxY {
                    guess += step
                } else {
                    result = indexPath
                    finished = true
                }
                step = Int(max(((CGFloat(step) + 0.5) / 2), 1))
                guess = min(totalRows, guess)
            } else {
                finished = true
            }
        }
        
        return result ?? IndexPath(row: -1, section: -1)
    }
    
    private func dropBackIfNecessary(touchLocation: CGPoint) {
        
        guard !done else {
            return
        }
        
        let leeway: CGFloat = 25
        
        let leftX = max(view.frame.minX - leeway - touchLocation.x, 0)
        let rightX = max(touchLocation.x - leeway - view.frame.maxX, 0)
        let outsideX = max(leftX, rightX)
        
        let topY = max(view.frame.minY - leeway - touchLocation.y, 0)
        let bottomY = max(touchLocation.y - leeway - view.frame.maxY, 0)
        let outsideY = max(topY, bottomY)
        
        let outsideMagnitude = max(1 - CGPoint(x: outsideX, y: outsideY).magnitude / 600, 0.8)
        
        let transform = CGAffineTransform(scaleX: outsideMagnitude * baseScale, y: outsideMagnitude * baseScale)
        
        UIView.animate(withDuration: 0.1) {
            self.view.transform = transform
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.parentMenu?.transform(outsideMagnitude)
        }
    }
    
    private func fullSize() {
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 2, options: .curveEaseInOut) {
            self.view.transform = CGAffineTransform(scaleX: self.baseScale, y: self.baseScale)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.parentMenu?.fullSize()
        }
    }
    
    private func transform(_ scale: CGFloat) {
        
        let scale = pow(scale, 1.5)
        let transform = CGAffineTransform(scaleX: scale * baseScale, y: scale * baseScale)
        
        UIView.animate(withDuration: 0.1) {
            self.view.transform = transform
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.parentMenu?.transform(scale)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuContent.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuContent[section].menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuRowCell.cellIdentifier, for: indexPath) as! MenuRowCell
        
        let rowPosition: MenuRowCell.RowPosition
        
        if indexPath.section == 0, indexPath.row == 0 {
            rowPosition = .top
        } else if indexPath.section == menuContent.count - 1, indexPath.row == menuContent[menuContent.count - 1].menuItems.count - 1 {
            rowPosition = .bottom
        } else {
            rowPosition = .other
        }
        
        let menuItem = menuContent[indexPath.section].menuItems[indexPath.row]
        cell.configure(with: menuItem, accentColor: menuAccentColor, backgroundColor: menuBackgroundColor, font: font?.uiFont(), rowPosition: rowPosition, containingView: containingView) { [weak self, weak tableView] in
            
            guard let self = self, let tableView = tableView else {
                return
            }
            
            let cellRect = tableView.rectForRow(at: indexPath)
            let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let positionInSuperview = tableView.convert(cellPosition, to: self.containingView)
            
            self.menuItemWasTapped(menuItem, indexPath: indexPath, position: CGPoint(x: positionInSuperview.x, y: positionInSuperview.y - cellRect.height / 2))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: Self.sectionHeaderHeight)))
        view.backgroundColor = Self.sectionHeaderColor
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : Self.sectionHeaderHeight
    }
}
