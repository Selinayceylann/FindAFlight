//
//  seyahatTableViewCell.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 30.05.2024.
//

import UIKit

class seyahatTableViewCell: UITableViewCell {

    @IBOutlet weak var ucusNo: UILabel!
    @IBOutlet weak var tarihi: UILabel!
    @IBOutlet weak var ucrett: UILabel!
    @IBOutlet weak var koltukNo: UILabel!
    @IBOutlet weak var varis: UILabel!
    @IBOutlet weak var kalkis: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func iptalButton(_ sender: Any) {
        guard let superView = self.superview as? UITableView else {
               return
           }
           guard let indexPath = superView.indexPath(for: self) else {
               return
           }

           let viewController = superView.delegate as? SeyahatlerViewController
           viewController?.iptalButtonPressed(indexPath: indexPath)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
