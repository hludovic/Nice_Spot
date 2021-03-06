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
    @IBOutlet weak var commentsView: CommentScrollView!
    @IBOutlet weak var commentButton: UIButton!
    
    private var contentManager: DetailContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(image: UIImage(named: "square.and.arrow.up"), style: .plain, target: self, action: #selector(displayOpenInMap))
        navigationItem.rightBarButtonItem = button
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
    
    @IBAction func commentButton(_ sender: UIButton) {
        contentManager.loadUserComment()
    }
    
    @objc func displayOpenInMap() {
        let alertController = UIAlertController(title: "Open in map", message: "Do you want to consult the location on Maps ?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Get Directions", style: .default) { _ in
            self.contentManager.openInMap()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
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
    
    func displayErrorMessage(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}

extension DetailViewController: CommentViewDelegate {
    
    func commentOperationSucceed(comment: Comment.Item) {
        contentManager.refreshComments()
    }
    
}

extension DetailViewController: DetailContentDelegate {
    
    func displayCommentScrollView() {
        guard contentManager.comments.count > 0 else { return }
        commentsView.clearContent()
        commentsView.loadComments(comments: contentManager.comments)
    }
    
    func displayCommentButton(mode: CommentViewController.Mode) {
        commentButton.isHidden = false
        switch mode {
        case .Edit:
            commentButton.setTitle(" Edit your comment", for: .normal)
        case .Save:
            commentButton.setTitle(" Save a comment", for: .normal)
        }
    }
    
    func displayPostCommentView() {
        let commentView = CommentViewController(
            nibName: "CommentViewController",
            bundle: nil, comment: contentManager.userComment,
            mode: .Save, spotId: contentManager.spot.id
        )
        commentView.delegate = self
        present(commentView, animated: true, completion: nil)
    }
    
    func displayEditCommentView() {
        let commentView = CommentViewController(
            nibName: "CommentViewController",
            bundle: nil, comment: contentManager.userComment,
            mode: .Edit, spotId: contentManager.spot.id
        )
        commentView.delegate = self
        present(commentView, animated: true, completion: nil)
    }
    
    func refreshFavorite() {
        favoriteButton.setImage(contentManager.favoriteButtonIcon, for: .normal)
    }
    
    func displayError(_ text: String) {
        DispatchQueue.main.async {
            self.displayErrorMessage(message: text)
        }
    }
    
    func imageLoaded(_ loaded: Bool) {
        if loaded {
            imageSpot.image = contentManager.image
        }
    }

}
