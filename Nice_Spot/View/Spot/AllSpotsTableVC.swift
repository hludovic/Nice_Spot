//
//  TableViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 25/03/2021.
//

import UIKit

class AllSpotsTableVC: UITableViewController {
    private var spots: [Spot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let titleView = spots.first?.category {
            navigationItem.title = "All \(titleView)s"
        }
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")

    }

    init(nibName: String, bundle nibBundleOrNil: Bundle?, spots: [Spot]) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        self.spots = spots
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spots.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = spots[indexPath.row].title
        cell.municipalityLabel.text = spots[indexPath.row].municipality
        cell.categoryLabel.text = spots[indexPath.row].category
        cell.loadImage(imageName: spots[indexPath.row].imageName!)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let spot = spots[indexPath.row]
        let vc = DetailViewController(nibName: "DetailViewController", bundle: nil, spot: spot)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 67
    }

}
