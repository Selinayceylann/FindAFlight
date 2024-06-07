//
//  HesabimViewController.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import UIKit
import Firebase

class HesabimViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var kullaniciAdi: UILabel!    
    @IBOutlet weak var tableView: UITableView!
    
    var hesabimMenu = [String]()
    var hesabimResim: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        hesabimMenu.append("Kuponlarım")
        hesabimMenu.append("Ayarlar")
        hesabimMenu.append("Yardım")
        hesabimMenu.append("Hakkımızda")
        hesabimMenu.append("Çıkış Yap")
        
        if let image1 = UIImage(systemName: "gift.circle") {
            hesabimResim.append(image1)
        }
        if let image2 = UIImage(systemName: "questionmark.circle") {
            hesabimResim.append(image2)
        }
        if let image3 = UIImage(systemName: "gearshape") {
            hesabimResim.append(image3)
        }
        if let image4 = UIImage(systemName: "info.circle") {
            hesabimResim.append(image4)
        }
        if let image5 = UIImage(systemName: "power.circle") {
            hesabimResim.append(image5)
        }
        imageView.image = UIImage(systemName: "person.fill")
        
        if let user = Auth.auth().currentUser {
                kullaniciAdi.text = user.email
            } else {
                kullaniciAdi.text = "Kullanıcı yok"
            }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menu", for: indexPath) as! HesabimTableViewCell
        cell.kuponImage.image = hesabimResim[indexPath.row]
        cell.kuponLabel.text = hesabimMenu[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 { // 5. hücreye tıklanırsa
                // Başka bir view'e geçiş yap
            do {
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "toCikisVC", sender: nil)
            } catch {
                print("Error")
            }
            
            }
        }

}
