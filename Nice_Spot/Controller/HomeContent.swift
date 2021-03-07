//
//  HomeContent.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 25/02/2021.
//

import Foundation
import CoreData

protocol HomeContentDelegate: AnyObject {
    func displayError(_ text: String)
}

class HomeContent {
    
    // MARK: - Properties
    
    weak var displayDelegate: HomeContentDelegate?
    private(set) var spots: [Spot] = []
    private(set) var errorMessage: String? {
        didSet { displayDelegate?.displayError(errorMessage!) }
    }
    private(set) var usedCategories: [String] = []
    
    // MARK: - Public Methods
    
    func loadSpots(context: NSManagedObjectContext, success: @escaping (Bool) -> Void) {
        Spot.getSpots(context: context) { [unowned self] (result) in
            self.spots = result
            self.getUsedCategories()
            return success(true)
        }
    }
    
    func refreshSpots (context: NSManagedObjectContext, success: @escaping (Bool) -> Void) {
        Spot.refreshSpots(context: context) { [unowned self] (refreshed) in
            guard refreshed else {
                errorMessage = "Error: Not refreshed"
                return success(false)
            }
            Spot.getSpots(context: context) { [unowned self] (spotsFetched) in
                spots = spotsFetched
                getUsedCategories()
                return success(true)
            }
        }
    }
    
    func getSpotsBy(category: String) -> [Spot] {
        guard !spots.isEmpty else { return [] }
        var spotList: [Spot] = []
        for spot in spots {
            guard let categoryString = spot.category else { return [] }
            if categoryString == category {
                spotList.append(spot)
            }
        }
        return spotList
    }
    
}

// MARK: - Private Method

private extension HomeContent {
    
    func getUsedCategories() {
        usedCategories = []
        for category in Spot.Category.allCases {
            for spot in spots {
                guard let categoryString = spot.category else { return }
                if categoryString == category.rawValue {
                    usedCategories.append(categoryString)
                    break
                }
            }
        }
    }
    
}
