//
//  HesabimTableViewCell.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import UIKit

class HesabimTableViewCell: UITableViewCell {

    @IBOutlet weak var kuponLabel: UILabel!
    @IBOutlet weak var kuponImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
