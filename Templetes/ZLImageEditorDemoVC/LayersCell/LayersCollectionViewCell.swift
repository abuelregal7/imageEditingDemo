//
//  LayersCollectionViewCell.swift
//  Templetes
//
//  Created by ahmed abu elregal on 22/05/2023.
//

import UIKit

class LayersCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var layersBackgroundImage: UIImageView!
    @IBOutlet weak var layersImage: UIImageView!
    @IBOutlet weak var layersView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .clear
        containerView.layer.cornerRadius = 12
        containerView.layer.masksToBounds = true
        containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.8).cgColor
        containerView.layer.borderWidth = 1
        
        layersBackgroundImage.layer.cornerRadius = 12
        layersBackgroundImage.layer.masksToBounds = true
    }

}
