//
//  ViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    private let content = HomeContent()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        content.displayDelegate = self
        loadRefreshControll()
        loadContent()
        navigationItem.title = "Découvrir"
    }
    
}

private extension HomeViewController {
    
    @objc func handleRefreshControl() {
        content.refreshSpots(context: PersistenceController.shared.container.viewContext) { (success) in
            if success {
                DispatchQueue.main.async { self.removeStackViewContent() }
                self.fillContent()
            }
        }
    }
    
    func loadRefreshControll() {
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    func loadContent() {
        content.loadSpots(context: PersistenceController.shared.container.viewContext) { (_ ) in
            self.fillContent()
        }
    }
    
    func removeStackViewContent() {
        for item in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(item)
        }
    }
    
    func fillContent() {
        let cagegories = self.content.usedCategories
        for category in cagegories {
            DispatchQueue.main.async {
                let scrollView = SpotScrollView(spots: self.content.getSpotsBy(category: category), category: category)
                scrollView.displayDelegate = self
                scrollView.heightAnchor.constraint(equalToConstant: 185).isActive = true
                self.stackView.addArrangedSubview(scrollView)
                self.scrollView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func displayErrorMessage(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}

extension HomeViewController: SpotScrollDisplayDelegate {
    
    func displayDetail(_ spot: Spot?) {
        guard let spot = spot else { return }
        let vc = DetailViewController(nibName: "DetailViewController", bundle: nil, spot: spot)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func displayAll(_ spots: [Spot]?) {
        guard let spots = spots else { return }
        let tableVC = AllSpotsTableVC(nibName: "AllSpotsTableVC", bundle: nil, spots: spots)
        navigationController?.pushViewController(tableVC, animated: true)
    }
        
}

extension HomeViewController: HomeContentDelegate {
    
    func displayError(_ text: String) {
        DispatchQueue.main.async {
            self.displayErrorMessage(message: text)
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
}

