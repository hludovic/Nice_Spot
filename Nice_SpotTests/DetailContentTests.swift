//
//  DetailContentTests.swift
//  Nice_SpotTests
//
//  Created by Ludovic HENRY on 07/03/2021.
//

import XCTest
import CoreData
@testable import Nice_Spot

class DetailContentTests: XCTestCase {
    var viewContext: NSManagedObjectContext!
//    let comment = Comment.Item( id: "", title: "Title Test Comment2", detail: "Detail Test Comment",
//                                authorID: "", authorPseudo: "Me", creationDate: Date()
//    )
    var content: DetailContent!
    
    override func setUp() {
        super.setUp()
        self.viewContext = loadTestableContext()
        removeComment()
        self.content = loadFakeDetailContent()
    }
    
    
    
    
        
}



private extension DetailContentTests {

    func loadFakeDetailContent() -> DetailContent {
        FakeData.saveFakeSpots(context: viewContext)
        let spot = FakeData.getFakeSpot(context: viewContext, title: "La Plage de l’Anse Rifflet")
        let content = DetailContent(spot: spot, context: viewContext)
        if !content.spot.isFavorite(context: viewContext) {
            content.pressFavoriteButton()
        }
        return content
    }
//
//    func loadWrongSpotIdDetailContent() -> DetailContent {
//        FakeData.saveFakeSpots(context: viewContext)
//        let spot = FakeData.getFakeSpot(context: viewContext, title: "Wrong Item")
//        let content = DetailContent(spot: spot, context: viewContext)
//        content.userComment = comment
//        return content
//    }
//
    func removeComment() {
//        Thread.sleep(forTimeInterval: 1)
        let expectation = XCTestExpectation(description: "Removing Comment")
        Comment.removeComment(spotId: FakeData.testableSpotId) { (success) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
//        Thread.sleep(forTimeInterval: 1)
    }

    func loadTestableContext() -> NSManagedObjectContext {
        let persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext
        return viewContext
    }

}
