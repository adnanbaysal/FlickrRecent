//
//  TableViewCell.swift
//  PhotosList
//
//  Created by Adnan Baysal on 11.05.2019.
//  Copyright © 2019 Adnan Baysal. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func didRequestDelete(_ cell: TableViewCell)
}

class TableViewCell: UITableViewCell {

    var delegate: TableViewCellDelegate?
    
    @IBOutlet weak var tableCellImageView: UIImageView!
    
    @IBOutlet weak var tableCellLabel: UILabel!
    
    @IBAction func deletePhoto(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.didRequestDelete(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bounds.size.height = 100
        
        tableCellLabel.contentMode = .scaleToFill
        tableCellLabel.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
