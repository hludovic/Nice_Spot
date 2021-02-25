//
//  ViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stackVIew: UIStackView!
    private let content = HomeContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.displayDelegate = self
        loadContent()
    }
    
    private func loadContent() {
        content.refreshSpots(context: PersistenceController.shared.container.viewContext) { (success) in
            if success {
                let cagegories = self.content.usedCategories
                for category in cagegories {
                    DispatchQueue.main.async {
                        let scrollView = SpotScrollView()
                        scrollView.loadSpots(spots: self.content.getSpotsBy(category: category), category: category)
                        self.stackVIew.addArrangedSubview(scrollView)
                    }
                }
            }
        }
    }
    

}

extension ViewController: HomeContentDelegate {
    func displayError(_ text: String) {
        print("Error")
    }
    
    func isLoading(_ activity: Bool) {
        if activity {
            DispatchQueue.main.async {
                print("Loading activity")

            }
        } else {
            DispatchQueue.main.async {
                print("Loading activity")

            }
        }
    }
}

