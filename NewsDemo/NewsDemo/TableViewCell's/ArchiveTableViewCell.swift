//
//  ArchiveTableViewCell.swift
//  NewsDemo
//
//  Created by Герман on 24.10.21.
//

import UIKit

class ArchiveTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageOfNews: UIImageView!
    @IBOutlet weak var labelDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        imageView?.layer.masksToBounds = true
        imageView?.layer.cornerRadius = 20
        
        let readmoreFont = UIFont(name: "Helvetica", size: 15)
        let readmoreFontColor = UIColor.blue
        DispatchQueue.main.async {
            self.labelDescription.addTrailing(with: "...", moreText: "Show More", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
        }
        // Configure the view for the selected state
    }

}
