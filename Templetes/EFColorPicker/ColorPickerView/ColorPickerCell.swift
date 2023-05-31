//
//  ColorPickerCell.swift
//  Templetes
//
//  Created by ahmed abu elregal on 15/05/2023.
//

import Foundation
import UIKit

class ColorPickerCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    /// The reuse identifier used to register the UICollectionViewCell to the UICollectionView
    static let cellIdentifier = String(describing: ColorPickerCell.self)
    /// The checkbox use to show the tip on the cell
    var checkbox = GDCheckbox()
    
    //MARK: - Initializer
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    fileprivate func commonInit() {
        
        // Setup of checkbox
        checkbox.isUserInteractionEnabled = false
        checkbox.backgroundColor = .clear
        checkbox.isHidden = true
        checkbox.isOn = false
        
        self.addSubview(checkbox)
        
        // Setup constraints to checkbox
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: checkbox, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: checkbox, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: checkbox, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: checkbox, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
    }
    
}

import UIKit

struct DefaultValues {
    
    static let cellSize: CGSize = CGSize(width: 28, height: 28)
    static let insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    static let minimumLineSpacingForSectionAt: CGFloat = 5 //0
    static let minimumInteritemSpacingForSectionAt: CGFloat = 5 //0
}
