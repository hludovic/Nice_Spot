//
//  DetailViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 28/02/2021.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageSpot: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var imageCategory: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var municipalityLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var commentsView: UIView!
    
    private var contentManager: DetailContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentManager.displayDelegate = self
        loadContent()
    }
    
    init(nibName: String, bundle nibBundleOrNil: Bundle?, spot: Spot) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        let viewContext = PersistenceController.shared.container.viewContext
        contentManager = DetailContent(spot: spot, context: viewContext)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func pressFavoriteButton(_ sender: UIButton) {
        contentManager.pressFavoriteButton()
    }
    
}

private extension DetailViewController {
    
    func loadContent() {
        title = contentManager.spot.category
        guard let contentManager = contentManager else { return }
        contentManager.loadImage()
        contentManager.refreshFavoriteButtonStatus()
        titleLabel.text = contentManager.spot.title
        detailLabel.text = contentManager.spot.detail
        municipalityLabel.text = contentManager.spot.municipality
        imageCategory.image = UIImage(named: contentManager.spot.category)
        
        mapView.region = contentManager.mapRegion
        let annotation = MKPointAnnotation()
        annotation.title = contentManager.spot.title
        annotation.coordinate = contentManager.spot.location.coordinate
        mapView.addAnnotation(annotation)
        
        contentManager.refreshComments()
    }
    
}

extension DetailViewController: DetailContentDelegate {
    
    func refreshComments() {
        guard contentManager.comments.count > 0 else { return }
        commentsView.isHidden = false
        let comments = CommentScrollView(comments: contentManager.comments)
        commentsView.addSubview(comments)
        comments.fixInView(commentsView)
    }
    
    func refreshFavorite() {
        favoriteButton.setImage(contentManager.favoriteButtonIcon, for: .normal)
    }
    
    func displayError(_ error: String) {
        print(error)
    }
    
    func isSavingComment(_ saving: Bool) {
        
    }
    
    func imageLoaded(_ loaded: Bool) {
        if loaded {
            imageSpot.image = contentManager.image
        }
    }

}
