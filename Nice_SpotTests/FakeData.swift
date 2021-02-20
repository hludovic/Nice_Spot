//
//  FakeData.swift
//  Nice_SpotTests
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import Foundation
import CoreData
@testable import Nice_Spot

class FakeData {
    static let testableSpotId: String = "91421B70-BC40-C23A-09C8-8897C0D9F3B7"
        
    static func saveFakeSpots(context: NSManagedObjectContext) {
                
        // MARK: - Item Cascecr
        let cascecr = Spot(context: context)
        cascecr.category = Spot.Category.waterfall.rawValue
        cascecr.detail = """
Située sur la route de la Traversée sur Basse Terre, à un kilomètre de la Maison de la Forêt, cette petite cascade d’environ 10 mètres de hauteur est très facile d’accès. Un parking permet de vous stationner, où est également implanté un plan du tracé ainsi qu’un descriptif des espèces que vous pourrez rencontrer sur le parcours.
Un chemin ombragé par une végétation luxuriante, entièrement balisé le long de la rivière Corossol, vous emmènera en seulement une dizaine de minutes, face à cette jolie cascade en pleine forêt tropicale. Accessible à tous, il n’est pas nécessaire d’être bon marcheur pour aller voir la cascade aux Écrevisses, même les plus petits pourront y accéder sans aucun problème.
"""
        cascecr.id = "1D997030-81B2-7E64-4F62-87EAAD8EE7B3"
        cascecr.latitude = 16.179118967390906
        cascecr.longitude = -61.68083214438678
        cascecr.municipality = Spot.Municipality.petitBourg.rawValue
        cascecr.imageName = "cascecr"
        cascecr.title = "La Cascade aux Ecrevisses"

        // MARK: - Item Rifflet
        let rifflet = Spot(context: context)
        rifflet.category = Spot.Category.beach.rawValue
        rifflet.detail = """
La plage de l’Anse Rifflet se situe au nord de la belle Basse Terre. A une poignée de kilomètres de la bourgade de Deshaies, il faut tourner à gauche, dans une descente (panneau) pour y accéder.

Elle se trouve juste à côté de la très belle plage de la Perle. Les lieux ne sont pas connus du tourisme de masse. Ceux-ci préfèrent aller sur la jolie mais bien plus fréquentée plage de Grande Anse.

La plage de l’Anse Rifflet appelle au farniente et à la contemplation. Impossible de rater vos photos de cette plage, les lieux sont tout droit sortis d’une carte postale.
"""
        rifflet.id = testableSpotId
        rifflet.latitude = 16.336675
        rifflet.longitude = -61.785863
        rifflet.municipality = Spot.Municipality.deshaies.rawValue
        rifflet.imageName = "rifflet"
        rifflet.title = "La Plage de l’Anse Rifflet"
        
        // MARK: - Item Caravelle
        let caravelle = Spot(context: context)
        caravelle.category = Spot.Category.beach.rawValue
        caravelle.detail = """
Assurément une des plus belles plages en Guadeloupe ! La plage de la Caravelle, qui se trouve à Sainte-Anne, fait en effet figure de référence en terme de destination paradisiaque, puisqu’elle concentre tous les éléments qui la définissent comme les cocotiers toisant les touristes venus profiter des joies du sable blanc et des eaux cristallines, ainsi que des spots de plongée sous-marine ! Très fréquentée en raison de sa renommée, il est toutefois possible d’y profiter d’un moment de calme lors des douces soirées propres à la Guadeloupe.
"""
        caravelle.id = "075C8DEC-D2DB-D81C-43CC-B453D78E02E7"
        caravelle.latitude = 16.221350519784288
        caravelle.longitude = -61.39367191555051
        caravelle.municipality = Spot.Municipality.sainteAnne.rawValue
        caravelle.imageName = "caravelle"
        caravelle.title = "La Plage de la Caravelle"
        
        // MARK: - Item WrongItem
        let wrongItem = Spot(context: context)
        wrongItem.category = Spot.Category.beach.rawValue
        wrongItem.detail = "Test"
        wrongItem.id = "wrongItem"
        wrongItem.latitude = 16.221350519784288
        wrongItem.longitude = -61.39367191555051
        wrongItem.municipality = Spot.Municipality.sainteAnne.rawValue
        wrongItem.imageName = "wrong"
        wrongItem.title = "Wrong Item"
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    static func getFakeSpot(context: NSManagedObjectContext, title: String) -> Spot {
        let request: NSFetchRequest<Spot> = Spot.fetchRequest()
        let predicate = NSPredicate(format: "title == %@", title)
        request.predicate = predicate
        let result = try! context.fetch(request)
        return result.first!
    }

    static func clearSpots(context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Spot.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            completion(true)
        } catch {
            completion(false)
        }
        ImageManager.imageCache.removeAllObjects()
    }
    
    static func getFakeSpots(context: NSManagedObjectContext) -> [Spot] {
        let request: NSFetchRequest<Spot> = Spot.fetchRequest()
        let result = try! context.fetch(request)
        return result
    }
}
