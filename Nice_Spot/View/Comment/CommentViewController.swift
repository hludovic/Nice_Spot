//
//  CommentViewController.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 01/03/2021.
//

import UIKit

protocol CommentViewDelegate {
    func commentOperationSucceed(comment: Comment.Item)
}

class CommentViewController: UIViewController {

    enum Mode { case Save, Edit }
    
    var delegate: CommentViewDelegate?
    private var comment: Comment.Item?
    private var commentMode: Mode?
    private var spotId: String?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pseudoTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    init(nibName: String, bundle nibBundleOrNil: Bundle?, comment: Comment.Item, mode: Mode, spotId: String) {
        super.init(nibName: nibName, bundle: nibBundleOrNil)
        self.comment = comment
        self.commentMode = mode
        self.spotId = spotId
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }

    @IBAction func pressCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressSaveButton(_ sender: Any) {
        guard let mode = commentMode else { return }
        switch mode {
        case .Edit:
            updateUserComment { (success) in
                if success {
                    DispatchQueue.main.async { self.dismiss(animated: true, completion: nil) }
                }
            }
        case .Save:
            saveUserComment { (success) in
                if success {
                    DispatchQueue.main.async { self.dismiss(animated: true, completion: nil) }
                }
            }
        }
        
    }
    
    
}

private extension CommentViewController {
    
    func loadContent() {
        guard let mode = commentMode else { return }
        switch mode {
        case .Edit:
            guard let comment = comment else { return }
            titleLabel.text = "Edit your comment"
            pseudoTextField.text = comment.authorPseudo
            titleTextField.text = comment.title
            commentTextView.text = comment.detail
        case .Save:
            titleLabel.text = "Save a comment"
            pseudoTextField.text = ""
            titleTextField.text = ""
            commentTextView.text = ""
        }
    }
    
    func updateCommentItem() -> Bool {
        guard
            commentTextView.text != "",
            pseudoTextField.text != "",
            titleTextField.text != ""
        else { return false }
        
        guard
            let commentText = commentTextView.text,
            let titleComment = titleTextField.text,
            let pseudo = pseudoTextField.text
        else { return false }
        
        let comment = Comment.Item(
            id: "",
            title: titleComment,
            detail: commentText,
            authorID: "",
            authorPseudo: pseudo,
            creationDate: Date()
        )
        
        self.comment = comment
        return true
    }
    
    func isLoading(_ enabled: Bool) {
        saveButton.isEnabled = !enabled
        titleTextField.isEnabled = !enabled
        pseudoTextField.isEnabled = !enabled
        commentTextView.isEditable = !enabled
    }
    
    func updateUserComment(success: @escaping (Bool) -> Void) {
        isLoading(true)
        guard updateCommentItem() else {
            isLoading(false)
            return success(false)
        }
        guard let commentItem = comment, let spotId = spotId else {
            isLoading(false)
            return success(false)
        }
        
        Comment.editComment(spotId: spotId, item: commentItem) { [unowned self] (isEdited) in
            guard isEdited else {
                DispatchQueue.main.async {
                    isLoading(false)
                    print("ERROR EDDITING")
                }
                return success(false)
            }
            DispatchQueue.main.async {
                delegate?.commentOperationSucceed(comment: commentItem)
                isLoading(false)
            }
            return success(true)
        }
    }
    
    func saveUserComment(success: @escaping (Bool) -> Void) {
        isLoading(true)
        guard updateCommentItem() else {
            isLoading(false)
            return success(false)
        }
        guard let commentItem = comment, let spotId = spotId else {
            isLoading(false)
            return success(false)
        }
        Comment.postComment(spotId: spotId, item: commentItem) { [unowned self] (posted) in
            guard posted else {
                DispatchQueue.main.async {
                    isLoading(false)
                    print("ERROR SAVING")
                }
                return success(false)
            }
            DispatchQueue.main.async {
                delegate?.commentOperationSucceed(comment: commentItem)
                isLoading(false)
            }
            return success(true)
        }
    }

}
