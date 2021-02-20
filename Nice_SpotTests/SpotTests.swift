//
//  SpotTests.swift
//  Nice_SpotTests
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import XCTest
import CoreData
@testable import Nice_Spot

class SpotTests: XCTestCase {
    var viewContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        self.viewContext = loadTestableContext()
    }
    
    func testGetspots() {
        //Given Spots Saved
        FakeData.saveFakeSpots(context: viewContext)
        //When GetSpots
        Spot.getSpots(context: viewContext) { (spots) in
            //Then
            XCTAssertEqual(spots.count, 4)
        }
    }
    
    func testGivenSpotAreSaved_WhenSearchAWordThatExists_ThenSuccess() {
        //Given
        FakeData.saveFakeSpots(context: viewContext)
        
        //When
        Spot.searchSpots(context: viewContext, titleContains: "plage") { (spots) in
            XCTAssertEqual(spots.count, 2)
            for spot in spots {
                XCTAssertTrue(spot.title!.contains("Plage"))
            }
        }
    }
    
    func testGivenSpotAreSaved_WhenSearchAWordThatNotExists_ThenFailure() {
        //Given
        FakeData.saveFakeSpots(context: viewContext)
        
        //When
        Spot.searchSpots(context: viewContext, titleContains: "Palge") { (spots) in
            //Then
            XCTAssertEqual(spots.count, 0)
        }
    }
    
    func testGiventSpotsAreSaved_WhenRefresh_ThenNewSpots() {
        //Given
        FakeData.saveFakeSpots(context: viewContext)
        Spot.getSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 4)
        }
        
        //When
        let expectation = XCTestExpectation(description: "Refreshing spots")
        Spot.refreshSpots(context: viewContext) { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        //Then
        Spot.getSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 10)
        }
    }
    
    func testGiventNoSpotsAreSaved_WhenRefresh_ThenNewSpots() {
        //Given
        Spot.getSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 0)
        }

        //When
        let expectation = XCTestExpectation(description: "Refreshing spots")
        Spot.refreshSpots(context: viewContext) { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        //Then
        Spot.getSpots(context: viewContext) { (spots) in
            XCTAssertEqual(spots.count, 10)
        }
    }
    
    func loadTestableContext() -> NSManagedObjectContext {
        let persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext
        return viewContext
    }

}
