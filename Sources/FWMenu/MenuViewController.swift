//
//  MenuViewController.swift
//  
//
//  Created by Franklyn Weber on 08/03/2021.
//

import UIKit


class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var containingView: UIView?
    
    var menuContent: [[FWMenuItem]] = [[]]
    var showSubmenu: ((FWMenuItem, CGPoint) -> ())!
    var finished: (() -> ())!
    
    private var isScrollingEnabled = true
    private let sectionHeaderHeight: CGFloat = 7
    private let sectionHeaderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 15
        view.layer.shadowRadius = 50
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.masksToBounds = false
        
        tableView.layer.cornerRadius = 15
        tableView.layer.masksToBounds = true
        tableView.backgroundColor = .systemGroupedBackground
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
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
        cell.configure(with: menuItem, rowPosition: rowPosition, containingView: containingView) { [weak self] in
            
            let cellRect = tableView.rectForRow(at: indexPath)
            let cellPosition = CGPoint(x: cellRect.midX, y: cellRect.midY)
            let positionInSuperview = tableView.convert(cellPosition, to: self?.containingView)
            
            self?.menuItemWasTapped(menuItem, position: positionInSuperview)
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
    
    var menuSize: CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let menuPadding: CGFloat = 20
        let availableWidth = screenSize.width - menuPadding * 2
        let availableHeight = screenSize.height - menuPadding * 2
        
        let rowPadding: CGFloat = 30
        var maxWidth = CGFloat.zero
        
        let totalHeight = menuContent.reduce(CGFloat.zero) {
            
            let section = $1
            
            let sectionHeight = section.reduce(CGFloat.zero) {
                
                let maxTextWidth: CGFloat
                let additionalPadding: CGFloat
                if $1.image == nil {
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
        
        let width = min(max(maxWidth, 170), availableWidth)
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


class MenuRowCell: UITableViewCell {
    
    static let cellIdentifier = "MenuRow"
    
    enum RowPosition {
        case bottom
        case other
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleImageConstraint: NSLayoutConstraint!
    
    private let lineColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
    
    
    func configure(with menuItem: FWMenuItem, rowPosition: RowPosition, containingView: UIView?, tapped: @escaping () -> ()) {
        
        titleLabel.text = menuItem.name
        
        if menuItem.hasSubmenus {
            iconImage.image = UIImage(systemName: "chevron.right")
        } else {
            iconImage.image = menuItem.image
        }
        
        switch menuItem.style {
        case .plain:
            titleLabel.textColor = .label
            iconImage.tintColor = .label
            backgroundColorView.backgroundColor = .systemGroupedBackground
        case .colored(let textColor, let iconColor, let backgroundColor):
            titleLabel.textColor = textColor
            iconImage.tintColor = iconColor ?? textColor
            backgroundColorView.backgroundColor = backgroundColor ?? .systemGroupedBackground
        }
        
        if titleTrailingConstraint == nil {
            titleTrailingConstraint = titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        }
        if titleImageConstraint == nil {
            titleImageConstraint = titleLabel.trailingAnchor.constraint(equalTo: iconImage.leadingAnchor)
        }
        
        if menuItem.image == nil {
            titleTrailingConstraint.constant = menuItem.image == nil ? 14 : 58
            titleTrailingConstraint.isActive = true
            titleImageConstraint.isActive = false
        } else {
            titleImageConstraint.isActive = true
            titleTrailingConstraint.isActive = false
        }
        
        switch rowPosition {
        case .bottom:
            lineView.backgroundColor = .clear
        case .other:
            lineView.backgroundColor = lineColor
        }
        
        let tapGestureRecognizer: UITapGestureRecognizer = .gestureRecognizer { _ in
            tapped()
        }
        addGestureRecognizer(tapGestureRecognizer)
    }
}
