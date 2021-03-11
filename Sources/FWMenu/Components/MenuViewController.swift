//
//  MenuViewController.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI
import CGExtensions


class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var containingView: UIView?
    weak var parentMenu: MenuViewController?
    
    var menuContent: [[FWMenuItem]] = [[]]
    var contentBackgroundColor: Color?
    var accentColor: Color?
    var font: Font?
    var sectionIndex: Int?
    var isTopMenu = true
    var showSubmenu: ((MenuViewController, FWMenuItem, Int, CGPoint) -> ())!
    var finished: (() -> ())!
    
    private var selectedRow: IndexPath?
    private var isScrollingEnabled = true
    private var done = false
    
    private let sectionHeaderHeight: CGFloat = 7
    private let sectionHeaderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    private let defaultBackgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    private let selectedBackgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    private let minMenuWidth: CGFloat = 250
    private let dragSensitivity: CGFloat = 250 // the lower the number, the more static the user's finger needs to be for the selection to occur
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let contentBackgroundColor = contentBackgroundColor {
            view.backgroundColor = UIColor(contentBackgroundColor).withAlphaComponent(0.9)
            tableView.backgroundColor = UIColor(contentBackgroundColor).withAlphaComponent(0.9)
        } else {
            view.backgroundColor = defaultBackgroundColor
            tableView.backgroundColor = defaultBackgroundColor
        }
        
        view.layer.cornerRadius = 15
        view.layer.shadowRadius = 50
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        
        tableView.layer.cornerRadius = 15
        tableView.layer.masksToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    var menuSize: CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let menuPadding = WindowViewController.menuPadding
        let availableWidth = screenSize.width - menuPadding * 2
        let availableHeight = screenSize.height - menuPadding * (UIDevice.hasNotch ? 6 : 3) // allow for status bar & notch
        
        let rowPadding: CGFloat = 32
        var maxWidth = CGFloat.zero
        
        let totalHeight = menuContent.reduce(CGFloat.zero) {
            
            let section = $1
            
            let sectionHeight = section.reduce(CGFloat.zero) {
                
                let maxTextWidth: CGFloat
                let additionalPadding: CGFloat
                if $1.image == nil && !$1.hasSubmenus {
                    maxTextWidth = availableWidth - rowPadding
                    additionalPadding = rowPadding
                } else {
                    maxTextWidth = availableWidth - rowPadding - 42
                    additionalPadding = rowPadding + 42
                }
                
                let size = $1.name.boundingRect(with: CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], context: nil).size
                let height = size.height + 22.5
                
                maxWidth = max(size.width + additionalPadding, maxWidth)
                
                return $0 + height
            }
            
            return $0 + sectionHeight + sectionHeaderHeight
        }
        
        let width = min(max(maxWidth, minMenuWidth), availableWidth)
        let height = min(totalHeight - sectionHeaderHeight, availableHeight)
        
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
        dropBackIfNecessary(touchLocation: gestureRecognizer.location(in: containingView))
        
        switch gestureRecognizer.state {
        case .began, .changed:
            guard let indexPath = indexPath(forRowAtOffset: touchLocation) else {
                finished()
                return
            }
            guard !isScrollingEnabled else {
                return
            }
            selectRow(at: indexPath)
        case .ended:
            
            selectRow(at: nil)
            self.fullSize()
            
            guard !isScrollingEnabled, gestureRecognizer.velocity(in: tableView).magnitude < dragSensitivity, let indexPath = indexPath(forRowAtOffset: touchLocation) else {
                return
            }
                
            let cellRect = tableView.rectForRow(at: indexPath)
            let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let positionInSuperview = tableView.convert(cellPosition, to: containingView)
            
            let menuItem = menuContent[indexPath.section][indexPath.row]
            menuItemWasTapped(menuItem, section: indexPath.section, position: positionInSuperview)
            
        default:
            selectRow(at: nil)
            self.fullSize()
        }
    }
    
    func refreshContent(_ content: [[FWMenuItem]]) {
        
        menuContent = content
        done = false
        
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }
}


// MARK: - Private
extension MenuViewController {
    
    private func menuItemWasTapped(_ menuItem: FWMenuItem, section: Int, position: CGPoint) {
        
        guard !done else {
            return
        }
        
        done = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.done = false
        }
        
        if menuItem.hasSubmenus {
            showSubmenu(self, menuItem, section, position)
        } else {
            menuItem.action?()
            finished()
        }
        
        isTopMenu = false
    }
    
    private func selectRow(at indexPath: IndexPath?) {
        
        if let selectedRow = selectedRow, selectedRow != indexPath {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
        if let indexPath = indexPath {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            if indexPath != selectedRow {
                UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.5)
            }
        }
        
        selectedRow = indexPath
    }
    
    private func indexPath(forRowAtOffset offset: CGPoint) -> IndexPath? {
        
        // don't know if there's a better way of finding the row for a particular y position, when there are varying row heights
        // in any case, this is super quick as it's just a binary search
        
        guard offset.x > 0 && offset.x < tableView.frame.width else {
            return nil
        }
        
        let tableHeight = tableView.contentSize.height
        let totalRows = menuContent.reduce(0) { $0 + $1.count }
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
                let itemsCount = items.count
                if pointer >= itemsCount {
                    pointer -= items.count
                    sectionIndex += 1
                } else {
                    indexPath = IndexPath(row: pointer, section: sectionIndex)
                }
            }
            
            if let indexPath = indexPath, indexPath.row >= 0 {
                let rowRect = tableView.rectForRow(at: indexPath).inset(by: UIEdgeInsets(top: indexPath.row == 0 ? -sectionHeaderHeight : 0, left: 0, bottom: 0, right: 0))
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
        
        return result
    }
    
    private func dropBackIfNecessary(touchLocation: CGPoint) {
        
        let leeway: CGFloat = 25
        
        let leftX = max(view.frame.minX - leeway - touchLocation.x, 0)
        let rightX = max(touchLocation.x - leeway - view.frame.maxX, 0)
        let outsideX = max(leftX, rightX)
        
        let topY = max(view.frame.minY - leeway - touchLocation.y, 0)
        let bottomY = max(touchLocation.y - leeway - view.frame.maxY, 0)
        let outsideY = max(topY, bottomY)
        
        let outsideMagnitude = max(1 - CGPoint(x: outsideX, y: outsideY).magnitude / 600, 0.8)
        
        let transform = CGAffineTransform(scaleX: outsideMagnitude, y: outsideMagnitude)
        
        UIView.animate(withDuration: 0.1) {
            self.view.transform = transform
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.parentMenu?.transform(outsideMagnitude)
        }
    }
    
    private func fullSize() {
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 2, options: .curveEaseInOut) {
            self.view.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.parentMenu?.fullSize()
        }
    }
    
    private func transform(_ scale: CGFloat) {
        
        let scale = pow(scale, 1.5)
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        
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
        return menuContent[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuRowCell.cellIdentifier, for: indexPath) as! MenuRowCell
        
        let rowPosition: MenuRowCell.RowPosition
        
        if indexPath.section == menuContent.count - 1, indexPath.row == menuContent[menuContent.count - 1].count - 1 {
            rowPosition = .bottom
        } else {
            rowPosition = .other
        }
        
        let menuItem = menuContent[indexPath.section][indexPath.row]
        cell.configure(with: menuItem, accentColor: accentColor, font: font, rowPosition: rowPosition, containingView: containingView) { [weak self, weak tableView] in
            
            guard let self = self, let tableView = tableView else {
                return
            }
            
            let cellRect = tableView.rectForRow(at: indexPath)
            let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let positionInSuperview = tableView.convert(cellPosition, to: self.containingView)
            
            self.menuItemWasTapped(menuItem, section: indexPath.section, position: CGPoint(x: positionInSuperview.x, y: positionInSuperview.y - cellRect.height / 2))
        }
        
        let bgView = UIView()
        
        if let contentBackgroundColor = contentBackgroundColor {
            bgView.backgroundColor = UIColor(contentBackgroundColor)
        } else {
            bgView.backgroundColor = selectedBackgroundColor
        }
        
        cell.selectedBackgroundView = bgView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: sectionHeaderHeight)))
        view.backgroundColor = sectionHeaderColor
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : sectionHeaderHeight
    }
}
