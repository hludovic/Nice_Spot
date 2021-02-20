//
//  Favorite.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import Foundation
import CoreData

extension Favorite {
        
    static func getFavoriteSpots(context: NSManagedObjectContext, completion: @escaping ([Spot]) -> Void) {
        var favSpots: [Spot] = []
        Spot.getSpots(context: context) { (spots) in
            Favorite.getFavorites(context: context) { (favorites) in
                for spot in spots {
                    for favorite in favorites {
                        if spot.id! == favorite.spotId! {
                            favSpots.append(spot)
                        }
                    }
                }
            }
        }
        completion(favSpots)
    }
    
    static func isFavorite(context: NSManagedObjectContext, spotId: String, completion: @escaping (Bool) -> Void) {
        getFavorites(context: context) { (favorites) in
            if !favorites.isEmpty {
                for favorite in favorites {
                    guard let favoriteId = favorite.spotId else { return }
                    if favoriteId == spotId {
                        return completion(true)
                    }
                }
                completion(false)
            } else {
                completion(false)
            }
        }
    }
        
    static func saveSpotId(context: NSManagedObjectContext, spotId: String, success: @escaping (Bool) -> Void) {
        canSave(spotId: spotId, context: context) { (canSave) in
            guard canSave else { return success(false) }
            isFavorite(context: context, spotId: spotId) { (isFavorite) in
                guard !isFavorite else { return success(false) }
                let favorite = Favorite(context: context)
                favorite.spotId = spotId
                do {
                    try context.save()
                } catch {
                    success(false)
                }
                success(true)
            }
        }
    }
    
    static func remove(context: NSManagedObjectContext, spotId: String, success: @escaping (Bool) -> Void) {
        getFavorite(context: context, spotId: spotId) { (favorite) in
            guard let favorite = favorite else { return success(false) }
            context.delete(favorite)
            do {
                try context.save()
            } catch {
                success(false)
            }
            success(true)
        }
    }
}

private extension Favorite {
    
    static func canSave(spotId id: String, context: NSManagedObjectContext, success: @escaping (Bool) -> Void) {
        Spot.getSpots(context: context) { (spots) in
            for spot in spots {
                guard let spotId = spot.id else { return success(false) }
                if spotId == id {
                    return success(true)
                }
            }
            return success(false)
        }
    }
    
    static func getFavorite(context: NSManagedObjectContext, spotId: String, completion: @escaping (Favorite?) -> Void ) {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        let predicate = NSPredicate(format: "spotId == %@", spotId)
        request.predicate = predicate
        if let result = try? context.fetch(request){
            guard !result.isEmpty else { return completion(nil) }
            completion(result.first)
        } else { completion(nil) }
    }
    
    static func getFavorites(context: NSManagedObjectContext, completion: @escaping([Favorite]) -> Void ) {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        do {
            let result = try context.fetch(request)
            completion(result)
        } catch {
            print("error GetFavorites")
            completion([])
        }
    }
    
}
