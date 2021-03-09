//
//  CommentCellView.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 01/03/2021.
//

import UIKit

class CommentCell: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pseudoLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    private let kXIB_NAME = "CommentCell"
    private let cellSize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    init(comment: Comment.Item) {
        super.init(frame: cellSize)
        commonInit()
        loadComment(comment: comment)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func loadComment(comment: Comment.Item) {
        titleLabel.text = comment.title
        dateLabel.text = comment.creationDateString
        pseudoLabel.text = comment.authorPseudo
        commentLabel.text = comment.detail
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(kXIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
}
