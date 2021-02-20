//
//  Persistence.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import CoreData

class PersistenceController {
    
    // MARK: - CloudKit Static Property
    
    static let publicCKDB: CKDatabase = CKContainer(identifier: "iCloud.fr.hludovic.container1").publicCloudDatabase
    
    static var isICloudAvailable: Bool {
        if let _ = FileManager.default.ubiquityIdentityToken{
            return true
        } else { return false }
    }
    
    // MARK: - CoreData Static Property
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Nice_Spot")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
