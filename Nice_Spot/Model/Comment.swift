//
//  Comment.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 20/02/2021.
//

import Foundation
import CloudKit

class Comment {
    
    // MARK: - Public Static methods
    
    /// Retrieves all the comments posted on a Spot.
    /// - Parameters:
    ///   - ckDatabase: The CKDatabase used for this task.
    ///   - spotId: The ID of the spot you wish to querry.
    ///   - completion: The callback called after retrieval.
    /// Returns a table of Comment.Item containing the result of the query, or an Error if the task failed.
    static func getComments(spotId: String, completion: @escaping (Result<[Comment.Item], Error>) -> Void) {
        let record = CKRecord.ID(recordName: spotId)
        let reference = CKRecord.Reference(recordID: record, action: .none)
        let predicate = NSPredicate(format: "spot == %@", reference)
        let querry = CKQuery(recordType: "Comments", predicate: predicate)
        let operation = CKQueryOperation(query: querry)
        operation.desiredKeys = ["title", "detail", "pseudo"]
        var commentList: [Item] = []
        
        operation.recordFetchedBlock = { record in
            guard
                let title = record["title"] as? String,
                let detail = record["detail"] as? String,
                let authorPseudo = record["pseudo"] as? String,
                let authorID = record.creatorUserRecordID?.recordName,
                let creationDate = record.creationDate
            else { return }
            let commentFetched = Item(id: record.recordID.recordName,title: title, detail: detail, authorID: authorID, authorPseudo: authorPseudo, creationDate: creationDate)
            commentList.append(commentFetched)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(commentList))
            }
        }
        PersistenceController.publicCKDB.add(operation)
    }
    
    static func getUserComment(spotId: String, userId: String, completion: @escaping (Comment.Item?) -> Void) {
        getComments(spotId: spotId) { (result) in
            switch result {
            case .failure(_ ):
                completion(nil)
            case .success(let comments):
                for comment in comments {
                    if comment.authorID == userId {
                        return completion(comment)
                    }
                }
                completion(nil)
            }
        }
    }
    
    /// Post a comment on a spot.
    /// - Parameters:
    ///   - spotId: The ID of the spot to which this comment relates.
    ///   - title: The title of the comment.
    ///   - content: The content of the comment.
    ///   - pseudo: The pseudonym of the author of the comment.
    ///   - success: Dismiss if the task has been completed successfully.
    static func postComment(spotId: String, item: Item, success: @escaping (Bool) -> Void) {
        guard item.title != "", item.authorPseudo != "", item.detail != "" else { return success(false) }
        canPostComment(spotId: spotId, userId: "__defaultOwner__") { (canPostComment) in
            guard canPostComment else { return success(false) }
            guard item.title != "", item.detail != "", item.authorPseudo != "" else { return success(false) }
            guard PersistenceController.isICloudAvailable else { return success(false) }
            let commentRecord = CKRecord(recordType: "Comments")
            let reference = CKRecord.Reference(recordID: CKRecord.ID(recordName: spotId), action: .none)
            commentRecord["title"] = item.title as CKRecordValue
            commentRecord["detail"] = item.detail as CKRecordValue
            commentRecord["spot"] = reference
            commentRecord["pseudo"] = item.authorPseudo as CKRecordValue
            PersistenceController.publicCKDB.save(commentRecord) { (record, error) in
                guard error == nil else { return success(false) }
                success(true)
            }
        }
    }
    
    static func editComment(spotId: String, item: Item, success: @escaping (Bool) -> Void) {
        guard item.title != "", item.authorPseudo != "", item.detail != "" else { return success(false) }
        guard PersistenceController.isICloudAvailable else { return success(false) }
        getUserComment(spotId: spotId, userId: "__defaultOwner__") { (comment) in
            guard let comment = comment else { return success(false) }
            let recordId = CKRecord.ID(recordName: comment.id)
            PersistenceController.publicCKDB.fetch(withRecordID: recordId) { (record, errors) in
                guard let record = record else { return success(false) }
                record["title"] = item.title
                record["detail"] = item.detail
                record["pseudo"] = item.authorPseudo
                PersistenceController.publicCKDB.save(record) { (_ , error) in
                    guard error == nil else { return success(false) }
                    success(true)
                }
            }
        }
    }
    
    static func removeComment(spotId: String, success: @escaping (Bool) -> Void) {
        getUserComment(spotId: spotId, userId: "__defaultOwner__") { (comment) in
            guard let comment = comment else { return success(false) }
            guard comment.authorID == "__defaultOwner__" else { return success(false) }
            let recordId = CKRecord.ID(recordName: comment.id)
            PersistenceController.publicCKDB.delete(withRecordID: recordId) { (_, error) in
                guard error == nil else { return success(false) }
                success(true)
            }
        }
    }
    
}

// MARK: - Private Static methods

private extension Comment {
    static func doesRecordExists(recordId: String, completion: @escaping (Bool?) -> Void) {
        guard PersistenceController.isICloudAvailable else { return completion(nil) }
        let recordId = CKRecord.ID(recordName: recordId)
        PersistenceController.publicCKDB.fetch(withRecordID: recordId) { (record, error) in
            guard error == nil else { return completion(nil) }
            guard let record = record else { return completion(nil) }
            if record.recordID.recordName == recordId.recordName {
                return completion(true)
            } else {
                return completion(false)
            }
        }
    }
    
    static func canPostComment(spotId :String, userId: String, success: @escaping (Bool) -> Void) {
        guard PersistenceController.isICloudAvailable else { return success(false) }
        doesRecordExists(recordId: spotId) { (result) in
            guard let exists = result, exists else { return success(false) }
            Comment.getComments(spotId: spotId) { (result) in
                switch result {
                case .success(let comments):
                    guard !comments.isEmpty else { return success(true) }
                    var canComment = true
                    for comment in comments {
                        if comment.authorID == userId {
                            canComment = false
                        }
                    }
                    success(canComment)
                case .failure( _):
                    success(false)
                }
            }
        }
    }
    
}

// MARK: - Nested Struct

extension Comment {
    /// A structure that represents the comments
    struct Item: Identifiable {
        let id: String
        var title: String
        var detail: String
        let authorID: String
        var authorPseudo: String
        let creationDate: Date
        var creationDateString: String {
            let dateFormater = DateFormatter()
            dateFormater.dateStyle = .medium
            return dateFormater.string(from: creationDate)
        }
    }
    
}
