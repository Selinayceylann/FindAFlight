import UIKit
import FirebaseFirestore
import FirebaseAuth

class SeyahatlerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var seyahatlerTableView: UITableView!
    
    var satınAlinanBiletler: [BiletClass] = []
    var uye : UyeClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        seyahatlerTableView.delegate = self
        seyahatlerTableView.dataSource = self
        
        fetchBiletler()
    }
    
    func fetchBiletler() {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("biletler")
                .whereField("kullaniciMail", isEqualTo: user?.email)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        self.satınAlinanBiletler.removeAll()
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            let bilet = BiletClass(
                                ucusNo: data["ucusNo"] as! Int,
                                koltukNo: data["koltukNo"] as! Int,
                                Ucret: data["ucret"] as! Int,
                                kalkisNoktasi: data["kalkisNoktasi"] as! String,
                                varisNoktası: data["varisNoktasi"] as! String,
                                ucusTarihi: data["ucusTarihi"] as! String,
                                uye: UyeClass(ad: "Ad", soyad: "Soyad", email: "", sifre: "", uyelikTarihi: Date(), yillikAlinanBilet: []), email: (user?.email)!
                            )
                            self.satınAlinanBiletler.append(bilet)
                        }
                        self.seyahatlerTableView.reloadData()
                    }
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return satınAlinanBiletler.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "biletler", for: indexPath) as! seyahatTableViewCell
        let bilet = satınAlinanBiletler[indexPath.row]
        
        cell.kalkis.text = "Kalkış: \(bilet.kalkisNoktasi)"
        cell.varis.text = "Varış: \(bilet.varisNoktası)"
        cell.koltukNo.text = "Koltuk No: \(bilet.koltukNo)"
        cell.ucrett.text = "Ücret: \(bilet.Ucret)"
        cell.tarihi.text = "Tarih: \(bilet.ucusTarihi)"
        cell.ucusNo.text = "Uçuş No: \(bilet.ucusNo)"
        
        return cell
    }
    
    func iptalButtonPressed(indexPath: IndexPath) {
        let bilet = satınAlinanBiletler[indexPath.row]
        
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("biletler")
                .whereField("ucusNo", isEqualTo: bilet.ucusNo)
                .whereField("koltukNo", isEqualTo: bilet.koltukNo)
                .whereField("kullaniciMail", isEqualTo: user?.email)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.delete { err in
                                if let err = err {
                                    print("Error: \(err)")
                                } else {
                                    print("İptal oldu!")
                                    self.satınAlinanBiletler.remove(at: indexPath.row)
                                    self.seyahatlerTableView.reloadData()
                                    self.updateYillikAlinanBiletCount()
                                    self.refundUser(biletUcreti: bilet.Ucret)
                                }
                            }
                        }
                    }
                }
        }
        
        
    }
    
    func updateYillikAlinanBiletCount() {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("uyeler").document(userId).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data() {
                        let ad = data["ad"] as? String ?? ""
                        let soyad = data["soyad"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let sifre = data["sifre"] as? String ?? ""
                        let uyelikTarihi = (data["uyelikTarihi"] as? Timestamp)?.dateValue() ?? Date()
                        var yillikAlinanBilet = data["yillikAlinanBilet"] as? [Int] ?? []
                        let bakiye = data["bakiye"] as? Double ?? 0.0
                        
                        self.uye = UyeClass(ad: ad, soyad: soyad, email: email, sifre: sifre, uyelikTarihi: uyelikTarihi, yillikAlinanBilet: yillikAlinanBilet)
                        
                        if let uye = self.uye {
                            let currentYear = Calendar.current.component(.year, from: Date())
                            let membershipYear = Calendar.current.component(.year, from: uye.uyelikTarihi)
                            let yearIndex = currentYear - membershipYear
                            
                            if yearIndex < yillikAlinanBilet.count {
                                yillikAlinanBilet[yearIndex] -= 1
                                
                                // Güncellenmiş yıllık alınan bilet sayısını Firestore'a kaydet
                                db.collection("uyeler").document(userId).updateData([
                                    "yillikAlinanBilet": yillikAlinanBilet
                                ]) { err in
                                    if let err = err {
                                        print("Yıllık alınan bilet sayısı güncellenemedi: \(err)")
                                    } else {
                                        print("Yıllık alınan bilet sayısı başarıyla güncellendi!")
                                    }
                                }
                            }
                        }
                    } else {
                        print("Kullanıcı bilgisi bulunamadı")
                    }
                }
            }
        }
    }
    
    
    func refundUser(biletUcreti: Int) {
        let refundAmount = Double(biletUcreti) * 0.75
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("uyeler").document(userId).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data() {
                        var bakiye = data["bakiye"] as? Double ?? 0.0
                        bakiye += refundAmount
                        
                        db.collection("uyeler").document(userId).updateData([
                            "bakiye": bakiye
                        ]) { err in
                            if let err = err {
                                print("Bakiye güncellenemedi: \(err)")
                            } else {
                                print("Bakiye başarıyla güncellendi!")
                            }
                        }
                    } else {
                        print("Kullanıcı bilgisi bulunamadı")
                    }
                }
            }
        }
        
    }
    
}
