//
//  FavoriteCell.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 06/03/2021.
//

import UIKit

class FavoriteCell: UITableViewCell {
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var municipalityLabel: UILabel!
    private let imageManager = ImageManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadImage(imageName: String) {
        imageManager.getUIImage(imageName: imageName) { [weak self] (uiImage) in
            guard let selfCell = self else { return }
            selfCell.imageCell.image = uiImage
        }
    }

}
