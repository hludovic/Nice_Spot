//
//  FavoriteTests.swift
//  Nice_SpotTests
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import XCTest
import CoreData

@testable import Nice_Spot

class FavoriteTests: XCTestCase {
    var viewContext: NSManagedObjectContext!
    let goodSpotId = "075C8DEC-D2DB-D81C-43CC-B453D78E02E7"

    override func setUp() {
        super.setUp()
        self.viewContext = loadTestableContext()
        
    }
    
    func testGivenFavoriteIsEmpty_WhenSavingAFavorite_ThenTheFavoriteIsStored() {
        FakeData.saveFakeSpots(context: viewContext)
        
        Favorite.getFavoriteSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 0)
        }

        Favorite.saveSpotId(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertTrue(success)
        }
        
        Favorite.getFavoriteSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 1)
            XCTAssertEqual(spots.first!.id!, self.goodSpotId)
        }
    }
    
    func testGivenSpotsAreSaved_WhenISaveAFalseID_ThenFailure() {
        FakeData.saveFakeSpots(context: viewContext)
        
        Favorite.saveSpotId(context: viewContext, spotId: "__FAIL_ID__") { (success) in
            XCTAssertFalse(success)
        }
    }

    func testGivenASpotIsFavorite_WhenSaveItFavoriteAgain_ThenFailure() {
        FakeData.saveFakeSpots(context: viewContext)

        Favorite.saveSpotId(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertTrue(success)
        }

        Favorite.saveSpotId(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertFalse(success)
        }
    }
    
    func testGivenAnIdIsSaved_WhenITestIfItIsFavorite_ThenItReturnsTrue() {
        FakeData.saveFakeSpots(context: viewContext)
        
        Favorite.saveSpotId(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertTrue(success)
        }
        
        Favorite.isFavorite(context: viewContext, spotId: goodSpotId) { (isFavorite) in
            XCTAssertTrue(isFavorite)
        }
    }

    func testGivenAnIdIsSaved_WhenITestAWrongIdIfItIsFavorite_ThenItReturnsFalse() {
        FakeData.saveFakeSpots(context: viewContext)

        Favorite.saveSpotId(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertTrue(success)
        }

        Favorite.isFavorite(context: viewContext, spotId: "__NOT_STORED_SPOT_ID__") { (success) in
            XCTAssertFalse(success)
        }
    }

    func testGivenAnIdIsSaved_WhenIDeleteThisFavorite_ThenItReturnsTrue() {
        FakeData.saveFakeSpots(context: viewContext)
        
        Favorite.getFavoriteSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 0)
        }
        Favorite.saveSpotId(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertTrue(success)
        }
        Favorite.getFavoriteSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 1)
            XCTAssertEqual(spots.first!.id!, self.goodSpotId)
        }

        Favorite.remove(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertTrue(success)
        }
        Favorite.getFavoriteSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 0)
        }

    }

    func testGivenNothingIsSaved_WhenIDeleteAFavorite_ThenItReturnsFalse() {
        FakeData.saveFakeSpots(context: viewContext)
        
        Favorite.getFavoriteSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 0)
        }

        Favorite.remove(context: viewContext, spotId: goodSpotId) { (success) in
            XCTAssertFalse(success)
        }
    }
    
    func loadTestableContext() -> NSManagedObjectContext {
        let persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext
        return viewContext
    }
}
