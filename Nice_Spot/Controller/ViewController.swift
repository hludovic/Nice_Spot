//
//  ViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var stackVIew: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: 250, height: 150)
        let cell = SpotHomeCell(frame: frame)
        let cell2 = SpotHomeCell(frame: frame)
        let cell3 = SpotHomeCell(frame: frame)
        
        stackVIew.alignment = .fill
        stackVIew.distribution = .fillEqually
        stackVIew.spacing = 10
        stackVIew.backgroundColor = .clear
        cell.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        stackVIew.addArrangedSubview(cell)
        stackVIew.addArrangedSubview(cell2)
        stackVIew.addArrangedSubview(cell3)
    }


}

