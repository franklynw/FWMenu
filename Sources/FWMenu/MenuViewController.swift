//
//  MenuViewController.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import SwiftUI


class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var containingView: UIView?
    
    var menuContent: [[FWMenuItem]] = [[]]
    var contentBackgroundColor: Color?
    var accentColor: Color?
    var font: Font?
    var showSubmenu: ((FWMenuItem, CGPoint) -> ())!
    var finished: (() -> ())!
    
    private var selectedRow: IndexPath?
    private var isScrollingEnabled = true
    private var done = false
    
    private let sectionHeaderHeight: CGFloat = 7
    private let sectionHeaderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    private let defaultBackgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    private let selectedBackgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    private let minMenuWidth: CGFloat = 250
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let contentBackgroundColor = contentBackgroundColor {
            view.backgroundColor = UIColor(contentBackgroundColor).withAlphaComponent(0.9)
            tableView.backgroundColor = UIColor(contentBackgroundColor).withAlphaComponent(0.9)
        } else {
            view.backgroundColor = defaultBackgroundColor//UIColor.systemGroupedBackground.withAlphaComponent(0.9)
            tableView.backgroundColor = defaultBackgroundColor//UIColor.systemGroupedBackground.withAlphaComponent(0.9)
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
        
        let panGestureRecognizer: UIPanGestureRecognizer = .gestureRecognizer { [weak self] recognizer in
            
            guard let self = self, !self.isScrollingEnabled else {
                return
            }
            
            let indexPath = self.indexPath(forRowAtOffset: recognizer.location(in: self.tableView).y)
            
            switch recognizer.state {
            case .began, .changed:
                self.selectRow(at: indexPath)
            case .ended:
                self.selectRow(at: nil)
                if let indexPath = indexPath {
                    
                    let cellRect = self.tableView.rectForRow(at: indexPath)
                    let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
                    let positionInSuperview = self.tableView.convert(cellPosition, to: self.containingView)
                    
                    let menuItem = self.menuContent[indexPath.section][indexPath.row]
                    self.menuItemWasTapped(menuItem, position: positionInSuperview)
                }
            default:
                self.selectRow(at: nil)
            }
        }
        panGestureRecognizer.delegate = self
        tableView.addGestureRecognizer(panGestureRecognizer)
    }
    
    var menuSize: CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let menuPadding: CGFloat = 20
        let availableWidth = screenSize.width - menuPadding * 2
        let availableHeight = screenSize.height - menuPadding * 2
        
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
                
//                let label = UILabel()
//                label.text = $1.name
//                label.font = .systemFont(ofSize: 17)
//                label.numberOfLines = 0
//                let size = label.sizeThatFits(CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude))
                
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
    
    private func menuItemWasTapped(_ menuItem: FWMenuItem, position: CGPoint) {
        
        guard !done else {
            return
        }
        
        done = true
        
        if menuItem.hasSubmenus {
            showSubmenu(menuItem, position)
        } else {
            menuItem.action?()
            finished()
        }
    }
    
    private func selectRow(at indexPath: IndexPath?) {
        
        if let selectedRow = selectedRow, selectedRow != indexPath {
            tableView.deselectRow(at: selectedRow, animated: false)
        }
        if let indexPath = indexPath {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        selectedRow = indexPath
    }
    
    private func indexPath(forRowAtOffset offset: CGFloat) -> IndexPath? {
        
        // don't know if there's a better way of finding the row for a particular y position, when there are varying row heights
        // in any case, this is super quick as it's just a binary search
        
        let tableHeight = tableView.contentSize.height
        let totalRows = menuContent.reduce(0) { $0 + $1.count }
        let sectionsCount = menuContent.count
        
        var guess = Int(offset / tableHeight * CGFloat(totalRows))
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
                if offset < rowRect.minY {
                    guess -= step
                } else if offset > rowRect.maxY {
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
}


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
        cell.configure(with: menuItem, accentColor: accentColor, font: font, rowPosition: rowPosition, containingView: containingView) { [weak self] in
            
            let cellRect = tableView.rectForRow(at: indexPath)
            let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let positionInSuperview = tableView.convert(cellPosition, to: self?.containingView)
            
            self?.menuItemWasTapped(menuItem, position: CGPoint(x: positionInSuperview.x, y: positionInSuperview.y - cellRect.height / 2))
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
        if section == 0 {
            return 0
        }
        return sectionHeaderHeight
    }
}


extension MenuViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
