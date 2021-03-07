//
//  ViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import UIKit

class ViewController: UIViewController, DisplaySpotDetailDelegate {
    
    func showDetail(_ spot: Spot?) {
        guard let spot = spot else { return }
        let vc = DetailViewController(nibName: "DetailViewController", bundle: nil, spot: spot)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    private let content = HomeContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.displayDelegate = self
        loadRefreshControll()
        loadContent()
        title = "AAA"
    }
    
    private func loadRefreshControll() {
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc private func handleRefreshControl() {
        content.refreshSpots(context: PersistenceController.shared.container.viewContext) { (success) in
            if success {
                let cagegories = self.content.usedCategories
                DispatchQueue.main.async { self.removeStackViewContent() }
                for category in cagegories {
                    DispatchQueue.main.async {
                        let scrollView = SpotScrollView(spots: self.content.getSpotsBy(category: category), category: category)
                        scrollView.displayDelegate = self
                        scrollView.heightAnchor.constraint(equalToConstant: 180).isActive = true
                        self.stackView.addArrangedSubview(scrollView)
                        self.stackView.isHidden = false
                        self.scrollView.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }
    
    private func loadContent() {
        content.loadSpots(context: PersistenceController.shared.container.viewContext) { (_ ) in
            self.fillContent()
        }
    }
    
    private func removeStackViewContent() {
        for item in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(item)
        }
    }
    
    private func fillContent() {
        let cagegories = self.content.usedCategories
        for category in cagegories {
            DispatchQueue.main.async {
                let scrollView = SpotScrollView(spots: self.content.getSpotsBy(category: category), category: category)
                scrollView.displayDelegate = self
                scrollView.heightAnchor.constraint(equalToConstant: 180).isActive = true
                self.stackView.addArrangedSubview(scrollView)
                self.scrollView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func displayErrorMessage(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}



extension ViewController: HomeContentDelegate {
    func displayError(_ text: String) {
        DispatchQueue.main.async {
            self.displayErrorMessage(message: text)
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
}

