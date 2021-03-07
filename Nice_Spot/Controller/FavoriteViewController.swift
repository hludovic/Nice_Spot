//
//  FavoriteTableViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 06/03/2021.
//

import UIKit

class FavoriteViewController: UITableViewController {
    private var spots: [Spot] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        navigationItem.title = "Favorite spots"
        Favorite.getFavoriteSpots(context: PersistenceController.shared.container.viewContext) { (spots) in
            self.spots = spots
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Favorite.getFavoriteSpots(context: PersistenceController.shared.container.viewContext) { (spots) in
            self.spots = spots
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    
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
