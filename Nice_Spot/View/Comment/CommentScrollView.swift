//
//  CommentListVIew.swift
//  Nice_Spot
//
//  Created by Ludovic HENRY on 01/03/2021.
//

import UIKit

class CommentScrollView: UIView {

    private let kXIB_NAME = "CommentScrollView"
    private let scrollSize: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(kXIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    func loadComments(comments: [Comment.Item]) {
        self.isHidden = false
        self.titleLabel.text = "Comments"
        guard comments.count > 0 else { return }
        for comment in comments {
            let cell = CommentCell(comment: comment)
            cell.widthAnchor.constraint(equalToConstant: 250).isActive = true
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.backgroundColor = .clear
            stackView.addArrangedSubview(cell)
        }
    }

    func clearContent() {
        for item in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(item)
        }
    }
}
