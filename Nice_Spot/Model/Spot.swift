//
//  Spot.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import Foundation
import CoreData

extension Spot {
    
    // MARK: - Public Static Methods
    
    /// This static method returns all values contained in the Spot entity.
    /// - Parameters:
    ///   - context: The NSManagedObjectContext used for this task.
    ///   - completion: Returns an array of Spot.
    static func getSpots(context: NSManagedObjectContext, completion: @escaping ([Spot]) -> Void) {
        let request: NSFetchRequest<Spot> = Spot.fetchRequest()
        if let result = try? context.fetch(request) {
            completion(result)
        } else { completion([]) }
    }
        
    /// Retrieves the Spots whose title contains the characters passed in parameter.
    /// - Parameters:
    ///   - context: The NSManagedObjectContext used for this task.
    ///   - titleContains: The characters we are going to search for.
    ///   - completion: The callback called after retrieval.
    /// Returns a table of Spot.Fetched containing the result of the query, or an empty array if the task failed.
    static func searchSpots(context: NSManagedObjectContext, titleContains: String, completion: @escaping ([Spot]) -> Void) {
        let request: NSFetchRequest<Spot> = Spot.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", titleContains)
        request.predicate = predicate
        if let result = try? context.fetch(request) {
            completion(result)
        } else { completion([])}
    }
    
    static func refreshSpots(context: NSManagedObjectContext, success: @escaping (Bool) -> Void) {
        fetchSpots { (spots) in
            guard !spots.isEmpty else { return success(false) }
            removeAllSpots(context: context) { (removed) in
                guard removed else { return success(false) }
                saveFetchedSpots(context: context, fetchedSpots: spots) { (saved) in
                    return success(saved)
                }
            }
        }
    }
    
}

// MARK: - Private Static Methods

private extension Spot {
    
    private static func fetchSpots(completion: @escaping ([Fetched]) -> Void) {
        let publicDB: CKDatabase = CKContainer(identifier: "iCloud.fr.hludovic.container1").publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let querry = CKQuery(recordType: "SpotCK", predicate: predicate)
        querry.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: querry)
        operation.desiredKeys = ["title", "detail", "category", "location", "municipality", "pictureName"]
        var newSpotsCK: [Fetched] = []
        
        operation.recordFetchedBlock = { record in
            guard
                let title = record["title"] as? String,
                let detail = record["detail"] as? String,
                let category = record["category"] as? String,
                let location = record["location"] as? CLLocation,
                let pictureName = record["pictureName"] as? String,
                let municipality = record["municipality"] as? String
            else { return completion([]) }
            let spotFetched = Fetched(recordID: record.recordID, title: title, detail: detail, category: category, location: location, pictureName: pictureName, municipality: municipality)
            newSpotsCK.append(spotFetched)
        }
        
        operation.queryCompletionBlock = { (cursor, error) in
            guard error == nil else { return completion([]) }
            completion(newSpotsCK)
        }
        publicDB.add(operation)
    }
    
    static func saveFetchedSpots(context: NSManagedObjectContext, fetchedSpots: [Fetched], success: @escaping (Bool) -> Void) {
        for fetchedSpot in fetchedSpots {
            let spot = Spot(context: context)
            spot.id = fetchedSpot.recordID.recordName
            spot.title = fetchedSpot.title
            spot.detail = fetchedSpot.detail
            spot.category = fetchedSpot.category
            spot.municipality = fetchedSpot.municipality
            spot.imageName = fetchedSpot.pictureName
            spot.latitude = fetchedSpot.location.coordinate.latitude
            spot.longitude = fetchedSpot.location.coordinate.longitude
            do {
                try context.save()
            } catch {
                success(false)
            }
        }
        success(true)
    }
    
    static func removeAllSpots(context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Spot")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("ERROR REMOVING")
            return completion(false)
        }
        completion(true)
    }
}


// MARK: - Enum

extension Spot {
    
    /// The list of categories in which a spot can be placed.
    enum Category: String, CaseIterable {
        case unknown = "Unknown"
        case beach = "Beach"
        case mountain = "Mountain"
        case river = "River"
        case waterfall = "Waterfall"
    }
    
    /// The list of municipalities in which a spot can be found.
    enum Municipality: String, CaseIterable {
        case basseTerre = "Basse-Terre"
        case anseBertrand = "Anse-Bertrand"
        case baieMahault = "Baie-Mahault"
        case baillif = "Baillif"
        case bouillante = "Bouillante"
        case capesterreBelleEau = "Capesterre-Belle-Eau"
        case capesterreDeMarieGalante = "Capesterre-de-Marie-Galante"
        case deshaies = "Deshaies"
        case gourbeyre = "Gourbeyre"
        case goyave = "Goyave"
        case grandBourg = "Grand-Bourg"
        case desirade = "La Désirade"
        case lamentin = "Lamentin"
        case leGosier = "Le Gosier"
        case leMoule = "Le Moule"
        case lesAbymes = "Les Abymes"
        case morneALEau = "Morne-à-l'Eau"
        case petitBourg = "Petit-Bourg"
        case petitCanal = "Petit-Canal"
        case pointeNoire = "Pointe-Noire"
        case pointeAPitre = "Pointe-à-Pitre"
        case portLouis = "Port-Louis"
        case saintClaude = "Saint-Claude"
        case saintFrancois = "Saint-François"
        case saintLouis = "Saint-Louis"
        case sainteAnne = "Sainte-Anne"
        case sainteRose = "Sainte-Rose"
        case terreDeBas = "Terre-de-Bas"
        case terreDeHaut = "Terre-de-Haut"
        case troisRivieres = "Trois-Rivières"
        case vieuxFort = "Vieux-Fort"
        case vieuxHabitants = "Vieux-Habitants"
    }
}

// MARK: - Nested Struct

extension Spot {
    
    /// A struct representing the result of a Spot request passed on CloudKit.
    struct Fetched {
        let recordID: CKRecord.ID
        let title: String
        let detail: String
        let category: String
        let location: CLLocation
        var pictureName: String
        var municipality: String
    }
}


