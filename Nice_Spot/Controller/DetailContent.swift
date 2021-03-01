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
    func isSavingComment(_ saving: Bool)
    func refreshFavorite()
    func imageLoaded(_ loaded: Bool)
}

class DetailContent {
    // MARK: - Public Property
    
    weak var displayDelegate: DetailContentDelegate?
    let spot: Item
    var mapRegion : MKCoordinateRegion
    private let context: NSManagedObjectContext
    var comments: [Comment.Item] = []
    var userComment : Comment.Item {
        didSet { refreshSaveButtonStatus() }
    }
    private(set) var isSaveButtonDisabled = true
    private(set) var canComment: Bool = false
    private(set) var image: UIImage = UIImage(named: "placeholder")!
    var displayCommentSheet: Bool = false {
        didSet { if displayCommentSheet && canComment { clearUserLoadedComment() } }
    }
    var favoriteButtonIcon: UIImage = UIImage(named: "bookmark")!
    
    // MARK: - Private Property
    
    private let imageManager = ImageManager()
    private var isLoading: Bool = false {
        didSet { refreshSaveButtonStatus() }
    }
    
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
    }
    
    // MARK: - Public Methods
    
    func refreshComments() {
        Comment.getComments(spotId: spot.id) { [unowned self] (result) in
            switch result {
            case .failure(_ ):
                DispatchQueue.main.async { displayDelegate?.displayError("ERROR LOADING COMMENTS") }
            case .success(let comments):
                DispatchQueue.main.async {
                    self.comments = comments
                    self.refreshCanCommentStatus(comments: comments)
                }
            }
        }
    }
    
    func loadUserComment(success: @escaping (Bool) -> Void) {
        Comment.getComments(spotId: spot.id) { [unowned self] (result) in
            switch result {
            case .failure(_ ):
                DispatchQueue.main.async { displayDelegate?.displayError("ERROR LOADING COMMENT") }
                return success(false)
            case .success(let comments):
                guard !comments.isEmpty else {
                    DispatchQueue.main.async { displayDelegate?.displayError("ERROR LOADING COMMENT") }
                    return success(false)
                }
                for comment in comments {
                    if comment.authorID == "__defaultOwner__" {
                        DispatchQueue.main.async {
                            self.userComment = comment
                            self.displayCommentSheet.toggle()
                        }
                        return success(true)
                    }
                }
            }
            DispatchQueue.main.async { displayDelegate?.displayError("ERROR LOADING COMMENT") }
            return success(false)
        }
    }
    
    func updateUserComment(success: @escaping (Bool) -> Void) {
        isLoading = true
        Comment.editComment(spotId: spot.id, item: userComment) { [unowned self] (isEdited) in
            guard isEdited else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    displayDelegate?.displayError("ERROR EDDITING")
                }
                return success(false)
            }
            DispatchQueue.main.async {
                successOperation()
                refreshComments()
            }
            return success(true)
        }
    }
    
    func saveUserComment(success: @escaping (Bool) -> Void) {
        isLoading = true
        Comment.postComment(spotId: spot.id, item: userComment) { [unowned self] (posted) in
            guard posted else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    displayDelegate?.displayError("ERROR SAVING")
                }
                return success(false)
            }
            DispatchQueue.main.async {
                successOperation()
                self.comments.append(Comment.Item(
                    id: "",
                    title: userComment.title,
                    detail: userComment.detail,
                    authorID: "",
                    authorPseudo: userComment.authorPseudo,
                    creationDate: Date())
                )
            }
            return success(true)
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
    
    func successOperation() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        isLoading = false
        displayCommentSheet = false
        canComment = false
        isSaveButtonDisabled = false
    }
    
    func refreshCanCommentStatus(comments: [Comment.Item]) {
        guard comments.count > 0 else { return canComment = true }
        for comment in comments {
            if comment.authorID == "__defaultOwner__" {
                canComment = false
            } else {
                canComment = true
            }
        }
    }
    
    func clearUserLoadedComment() {
        userComment.title = ""
        userComment.authorPseudo = ""
        userComment.detail = ""
    }
    
    func refreshSaveButtonStatus() {
        let isNotFill = (userComment.title == "" || userComment.authorPseudo == "") || (userComment.detail == "")
        isSaveButtonDisabled = isNotFill || isLoading
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
