//
//  SpotScrollView.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 24/02/2021.
//

import UIKit

class SpotScrollView: UIView, DisplaySpotDetailDelegate {
    
    func showDetail(_ spot: Spot?) {
        displayDelegate?.showDetail(spot)
    }
    
    var displayDelegate: DisplaySpotDetailDelegate?
    private let kXIB_NAME = "SpotScrollView"
    private let scrollSize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    private var category: String?
    private var spots: [Spot]?
    
    init(spots: [Spot], category: String) {
        super.init(frame: scrollSize)
        self.category = category
        self.spots = spots
        commonInit()
        loadSpots()
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
    
    func loadSpots() {
        guard let spots = self.spots else { return }
        guard let category = self.category else { return }
        titleLabel.text = category
        for spot in spots {
            let cell = SpotHomeCell(spot: spot)
            cell.displayDelegate = self
            cell.widthAnchor.constraint(equalToConstant: 250).isActive = true
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.backgroundColor = .clear
            stackView.addArrangedSubview(cell)
        }
    }
    
}
