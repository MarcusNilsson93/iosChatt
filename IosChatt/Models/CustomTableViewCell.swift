//
//  CustomTableViewCell.swift
//  IosChat
//
//  Created by Marcus Nilsson on 2021-05-26.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var Icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Icon.image = UIImage(systemName: "person.crop.circle")
        nameLable.text = "Unknown username"
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
