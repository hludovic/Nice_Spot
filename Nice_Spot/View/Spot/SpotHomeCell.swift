//
//  SpotHomeCell.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 23/02/2021.
//

import UIKit

protocol DisplaySpotDetailDelegate {
    func showDetail(_ spot: Spot?)
}
class SpotHomeCell: UIView {
    var displayDelegate: DisplaySpotDetailDelegate?
    private let kXIB_NAME = "SpotHomeCell"
    private let cellSize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var showDetailButton: UIButton!
    private let imageManager = ImageManager()
    private var spot: Spot?
    
    init(spot: Spot) {
        super.init(frame: cellSize)
        commonInit()
        loadSpot(spot: spot)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(kXIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    private func loadSpot(spot: Spot) {
        guard let spotTitle = spot.title else { return }
        guard let imageName = spot.imageName else { return }
        imageManager.getUIImage(imageName: imageName) { [weak self] (uiImage) in
            guard let newObject = self else { return }
            guard let uiImage = uiImage else { return }
            DispatchQueue.main.async {
                self?.spot = spot
                newObject.imageView.image = uiImage
                newObject.titleLabel.text = spotTitle
                newObject.showDetailButton.isEnabled = true
            }
        }
    }
    
    @IBAction func showDetail(_ sender: UIButton) {
        displayDelegate?.showDetail(spot)
    }
    
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

