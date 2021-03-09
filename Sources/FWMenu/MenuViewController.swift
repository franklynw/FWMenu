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
    
    private var isScrollingEnabled = true
    private let sectionHeaderHeight: CGFloat = 7
    private let sectionHeaderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    private let minMenuWidth: CGFloat = 250
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let contentBackgroundColor = contentBackgroundColor {
            view.backgroundColor = UIColor(contentBackgroundColor)
            tableView.backgroundColor = UIColor(contentBackgroundColor)
        } else {
            view.backgroundColor = .systemGroupedBackground
            tableView.backgroundColor = .systemGroupedBackground
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
                
                let size = $1.name.boundingRect(with: CGSize(width: maxTextWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], context: nil).size
                let height = size.height + 22
                
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
        
        if menuItem.hasSubmenus {
            showSubmenu(menuItem, position)
        } else {
            menuItem.action?()
            finished()
        }
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


