//
//  SpotScrollView.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 24/02/2021.
//

import UIKit

class SpotScrollView: UIView {
    private let kXIB_NAME = "SpotScrollView"
    private let cellSize: CGRect = CGRect(x: 0, y: 0, width: 250, height: 150)
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
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
    
    func loadSpots(spots: [Spot], category: String) {
        titleLabel.text = category
        for spot in spots {
            let cell = SpotHomeCell(frame: cellSize)
            cell.loadSpot(spot: spot)
            cell.widthAnchor.constraint(equalToConstant: 250).isActive = true
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.backgroundColor = .clear
            stackView.addArrangedSubview(cell)
        }
    }
    
}
