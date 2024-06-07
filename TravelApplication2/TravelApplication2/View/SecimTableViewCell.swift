//
//  SecimTableViewCell.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import UIKit

class SecimTableViewCell: UITableViewCell {

    @IBOutlet weak var ucret: UILabel!
    
    @IBOutlet weak var ucusNo: UILabel!
    @IBOutlet weak var nereye: UILabel!
    @IBOutlet weak var nereden: UILabel!
    @IBOutlet weak var sure: UILabel!
    @IBOutlet weak var logo: UILabel!
    @IBOutlet weak var saat: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
