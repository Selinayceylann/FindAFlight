//
//  RezervasyonTableViewCell.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 28.05.2024.
//

import UIKit

class RezervasyonTableViewCell: UITableViewCell {
    @IBOutlet weak var neredenRez: UILabel!
    @IBOutlet weak var kalanSureRez: UILabel!
    @IBOutlet weak var koltukNoRez: UILabel!
    @IBOutlet weak var tarihRez: UILabel!
    
    var iptalAction: (() -> Void)? // İptal butonu için closure


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func iptalButt(_ sender: Any) {
        iptalAction?() // Closure'ı çağır
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
