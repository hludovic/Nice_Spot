//
//  DetailContent.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 25/02/2021.
//

import Foundation
import UIKit
import MapKit
import CoreData

protocol DetailContentDelegate: AnyObject {
    func displayError(_ error: String)
    func refreshFavorite()
    func imageLoaded(_ loaded: Bool)
    func displayCommentScrollView()
    func displayPostCommentView()
    func displayEditCommentView()
    func displayCommentButton(mode: CommentViewController.Mode)
}

class DetailContent {
    
    // MARK: - Property
    
    let spot: Item
    weak var displayDelegate: DetailContentDelegate?
    var mapRegion : MKCoordinateRegion
    private(set) var userComment : Comment.Item
    private(set) var comments: [Comment.Item] = []
    private(set) var image: UIImage = UIImage(named: "placeholder")!
    private(set) var favoriteButtonIcon: UIImage
    private let imageManager = ImageManager()
    private let context: NSManagedObjectContext
    
    init(spot: Spot, context: NSManagedObjectContext) {
        let coodinate = CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)
        let item = Item(id: spot.id!,
                        title: spot.title!,
                        detail: spot.detail!,
                        imageName: spot.imageName!,
                        municipality: spot.municipality!,
                        category: spot.category!,
                        location: Location(coordinate: coodinate)
        )
        self.mapRegion = MKCoordinateRegion(
            center: coodinate,
            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        )
        self.spot = item
        self.userComment = Comment.Item(id: "", title: "", detail: "", authorID: "", authorPseudo: "", creationDate: Date())
        self.context = context
        self.favoriteButtonIcon = UIImage(named: "bookmark")!
    }
    
    // MARK: - Public Methods
    
    func refreshComments() {
        Comment.getComments(spotId: spot.id) { [unowned self] (result) in
            switch result {
            case .failure(_ ):
                DispatchQueue.main.async { displayDelegate?.displayError("ERROR LOADING COMMENTS") }
            case .success(let comments):
                self.comments = comments
                DispatchQueue.main.async { displayDelegate?.displayCommentScrollView() }
                
                for comment in comments {
                    if comment.authorID == "__defaultOwner__" {
                        DispatchQueue.main.async { displayDelegate?.displayCommentButton(mode: .Edit) }
                        return
                    }
                }
                DispatchQueue.main.async { displayDelegate?.displayCommentButton(mode: .Save) }
            }
        }
    }

    func loadUserComment() {
        
        Comment.getComments(spotId: spot.id) { [unowned self] (result) in
            switch result {
            case .failure(_ ):
                DispatchQueue.main.async { displayDelegate?.displayError("ERROR LOADING COMMENT") }
                return
            case .success(let comments):
                guard !comments.isEmpty else {
                    DispatchQueue.main.async { displayDelegate?.displayPostCommentView() }
                    return
                }
                for comment in comments {
                    if comment.authorID == "__defaultOwner__" {
                        DispatchQueue.main.async {
                            self.userComment = comment
                            displayDelegate?.displayEditCommentView()
                        }
                        return
                    }
                }
            }
            DispatchQueue.main.async { displayDelegate?.displayPostCommentView() }
            return
        }
    }
    
    
    func loadImage() {
        imageManager.getUIImage(imageName: spot.imageName) { [unowned self] (uiImage) in
            guard let uiImage = uiImage else { return }
            DispatchQueue.main.async {
                self.image = uiImage
                displayDelegate?.imageLoaded(true)
            }
        }
    }
    
    func refreshFavoriteButtonStatus() {
        if spot.isFavorite(context: context) {
            favoriteButtonIcon = UIImage(named: "bookmark.fill")!
            displayDelegate?.refreshFavorite()
        } else {
            favoriteButtonIcon = UIImage(named: "bookmark")!
            displayDelegate?.refreshFavorite()
        }
    }
    
    func pressFavoriteButton() {
        Favorite.isFavorite(context: context, spotId: spot.id) { [unowned self] (isFavorite) in
            let generator = UINotificationFeedbackGenerator()
            if isFavorite {
                Favorite.remove(context: self.context, spotId: self.spot.id) { [unowned self] (success) in
                    guard success else { return }
                    generator.notificationOccurred(.success)
                    self.refreshFavoriteButtonStatus()
                }
            } else {
                Favorite.saveSpotId(context: context, spotId: self.spot.id) { (success) in
                    guard success else { return }
                    generator.notificationOccurred(.success)
                    self.refreshFavoriteButtonStatus()
                }
            }
            displayDelegate?.refreshFavorite()
        }
    }
        
    func openInMap() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: spot.location.coordinate))
        item.name = spot.title
        item.openInMaps(launchOptions: nil)
    }
    
}

// MARK: - Private Methods

private extension DetailContent {
    
    func clearUserLoadedComment() {
        userComment.title = ""
        userComment.authorPseudo = ""
        userComment.detail = ""
    }
    
}

// MARK: - Nested Struct

extension DetailContent {
    
    struct Item {
        let id: String
        let title: String
        let detail: String
        let imageName: String
        let municipality: String
        let category: String
        let location: Location
        func isFavorite(context: NSManagedObjectContext) -> Bool {
            var returnValue = false
            Favorite.isFavorite(context: context, spotId: self.id) { (favorite) in
                if favorite {
                    returnValue = true
                } else {
                    returnValue = false
                }
            }
            return returnValue
        }
    }
    
    /// A structure representing a location that can be used as annotationItems in a Map.
    struct Location: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }
    
}
