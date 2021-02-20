//
//  CommentTests.swift
//  Nice_SpotTests
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import XCTest
@testable import Nice_Spot

class CommentTests: XCTestCase {
    let spotId = FakeData.testableSpotId
    let commentItem = Comment.Item(
        id: "", title: "title",
        detail: "comment", authorID: "",
        authorPseudo: "pseudo", creationDate: Date()
    )

    override func setUp() {
        super.setUp()
        removeComment()
    }
    
    // MARK: - Delete
    
    func testWhenDeletingCommentWithAWrongSpotId_ThenItFails() {
        let expectation = XCTestExpectation(description: "Posting Comment")
        Comment.removeComment(spotId: "AAA") { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGiventThereAreAComment_WhenDeleteThisComment_ThenSuccess() {
        //Given
        var expectation = XCTestExpectation(description: "Posting Comment")
        Comment.postComment(spotId: spotId, item: commentItem) { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
        
        expectation = XCTestExpectation(description: "Fetching comments")
        Comment.getComments(spotId: spotId) { (result) in
            switch result{
            case .failure(_ ): break
            case .success(let comments):
                XCTAssertEqual(comments.count, 1)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
        
        //When
        expectation = XCTestExpectation(description: "Removing Comment")
        Comment.removeComment(spotId: spotId) { (success) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
        
        //THEN
        expectation = XCTestExpectation(description: "Fetching comments")
        Comment.getComments(spotId: spotId) { (result) in
            switch result{
            case .failure(_ ): break
            case .success(let comments):
                XCTAssertEqual(comments.count, 0)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenThereAreNoComment_WhenRemovingAComment_ThenFailure() {
        //Given
        var expectation = XCTestExpectation(description: "Fetching comments")
        Comment.getComments(spotId: spotId) { (result) in
            switch result{
            case .failure(_ ):
                print("Error")
            case .success(let comments):
                XCTAssertEqual(comments.count, 0)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
        
        //When
        expectation = XCTestExpectation(description: "Removing Comment")
        Comment.removeComment(spotId: spotId) { (success) in
            //Then
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Save
    
    func testWhenCommentWithAWrongSpotId_ThenItFails() {
        let expectation = XCTestExpectation(description: "Posting Comment")
        Comment.postComment(spotId: "AAA", item: commentItem) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenCommentContainsEmptyContent_WhenSaveComment_ThenFailure() {
        // Empty Title
        var item = Comment.Item( id: "", title: "", detail: "comment", authorID: "",
            authorPseudo: "pseudo", creationDate: Date() )
        var expectation = XCTestExpectation(description: "Posting comments")
        Comment.postComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        // Empty Detail
        item = Comment.Item( id: "", title: "title", detail: "", authorID: "",
            authorPseudo: "pseudo", creationDate: Date() )
        expectation = XCTestExpectation(description: "Posting comments")
        Comment.postComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        // Empty Pseudo
        item = Comment.Item( id: "", title: "title", detail: "detail", authorID: "",
            authorPseudo: "", creationDate: Date() )
        expectation = XCTestExpectation(description: "Posting comments")
        Comment.postComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        // Empty Item
        item = Comment.Item( id: "", title: "", detail: "", authorID: "",
            authorPseudo: "", creationDate: Date() )
        expectation = XCTestExpectation(description: "Posting comments")
        Comment.postComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenThereAreNoComment_WhenIComment_ThenSuccess() {
        //Given
        var expectation = XCTestExpectation(description: "Fetching comments")
        Comment.getComments(spotId: spotId) { (result) in
            switch result{
            case .failure(_ ):
                print("Error")
            case .success(let comments):
                XCTAssertEqual(comments.count, 0)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        //When
        expectation = XCTestExpectation(description: "Posting Comment")
        Comment.postComment(spotId: spotId, item: commentItem) { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        //Then
        Thread.sleep(forTimeInterval: 3)
        expectation = XCTestExpectation(description: "Fetching Comment")
        Comment.getComments(spotId: spotId) { (result) in
            switch result{
            case .failure(_ ):
                print("Error")
            case .success(let comments):
                XCTAssertEqual(comments.count, 1)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenThereAreOneComment_WhenICommentAgain_ThenFailure() {
        //Given
        var expectation = XCTestExpectation(description: "Posting Comment")
        Comment.postComment(spotId: spotId, item: commentItem) { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
        
        //When
        expectation = XCTestExpectation(description: "Posting Comment Again")
        Comment.postComment(spotId: spotId, item: commentItem) { (success) in
            //Then
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Edit
    
    func testWhenEditingCommentWithAWrongSpotId_ThenItFails() {
        let expectation = XCTestExpectation(description: "Posting Comment")
        Comment.editComment(spotId: "AAA", item: commentItem) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()

        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGivenCommentContainsEmptyContent_WhenEditingComment_ThenFailure() {
        // Empty Title
        var item = Comment.Item( id: "", title: "", detail: "comment", authorID: "",
            authorPseudo: "pseudo", creationDate: Date() )
        var expectation = XCTestExpectation(description: "Posting comments")
        Comment.editComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        // Empty Detail
        item = Comment.Item( id: "", title: "title", detail: "", authorID: "",
            authorPseudo: "pseudo", creationDate: Date() )
        expectation = XCTestExpectation(description: "Posting comments")
        Comment.editComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        // Empty Pseudo
        item = Comment.Item( id: "", title: "title", detail: "detail", authorID: "",
            authorPseudo: "", creationDate: Date() )
        expectation = XCTestExpectation(description: "Posting comments")
        Comment.editComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        // Empty Item
        item = Comment.Item( id: "", title: "", detail: "", authorID: "",
            authorPseudo: "", creationDate: Date() )
        expectation = XCTestExpectation(description: "Posting comments")
        Comment.editComment(spotId: spotId, item: item) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    
    func testGivenThereAreOneComment_WhenEditing_ThenSuccess() {
        //Given
        var expectation = XCTestExpectation(description: "Posting Comment")
        Comment.postComment(spotId: spotId, item: commentItem) { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
        
        //When
        expectation = XCTestExpectation(description: "Editing Comment")
        let editedComment = Comment.Item(
            id: "", title: "Edited",
            detail: "Edited", authorID: "",
            authorPseudo: "pseudo", creationDate: Date()
        )
        Comment.editComment(spotId: spotId, item: editedComment) { (success) in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
        
        //Then
        expectation = XCTestExpectation(description: "User Comment")
        Comment.getUserComment(spotId: spotId, userId: "__defaultOwner__") { (comment) in
            XCTAssertNotNil(comment)
            if let comment = comment {
                XCTAssertEqual(comment.title, "Edited")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
    }
    
    func testGivenThereAreNoComment_WhenEditing_ThenFailure() {
        //Given
        var expectation = XCTestExpectation(description: "Fetching comments")
        Comment.getComments(spotId: spotId) { (result) in
            switch result{
            case .failure(_ ):
                print("Error")
            case .success(let comments):
                XCTAssertEqual(comments.count, 0)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        //When
        expectation = XCTestExpectation(description: "Editing Comment")
        Comment.editComment(spotId: spotId, item: commentItem) { (success) in
            XCTAssertFalse(success)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        Thread.sleep(forTimeInterval: 3)
    }
    
}

private extension CommentTests {
    
    func removeComment() {
        let expectation = XCTestExpectation(description: "Removing Comment")
        Comment.removeComment(spotId: spotId) { (success) in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

}
