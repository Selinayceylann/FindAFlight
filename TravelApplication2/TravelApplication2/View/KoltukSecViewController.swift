import UIKit
import FirebaseAuth
import FirebaseFirestore

class KoltukSecViewController: UIViewController {
    
    var ucus: UcusClass?
    var selectedKoltukNo: Int?
    var uye: UyeClass? // Kullanıcı bilgileri
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
        ])
        
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        
        // Kullanıcının bilgilerini Firebase'den çek ve UyeClass nesnesine ata
        fetchUserData()
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        db.collection("uyeler").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    let ad = data["ad"] as? String ?? ""
                    let soyad = data["soyad"] as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let sifre = data["sifre"] as? String ?? ""
                    let uyelikTarihi = (data["uyelikTarihi"] as? Timestamp)?.dateValue() ?? Date()
                    let yillikAlinanBilet = data["yillikAlinanBilet"] as? [Int] ?? []
                    let bakiye = data["bakiye"] as? Double ?? 0.0


                    self.uye = UyeClass(ad: ad, soyad: soyad, email: email, sifre: sifre, uyelikTarihi: uyelikTarihi, yillikAlinanBilet: yillikAlinanBilet)
                }
            } else {
                print("Kullanıcı bilgisi bulunamadı")
            }
        }
    }
    
    @IBAction func birNumaraKoltuk(_ sender: Any) {
        if uye?.uyelikTipi() == "VIP" {
            selectedKoltukNo = 1
        } else {
            showVIPAlert()
        }
    }
    
    @IBAction func ikiNumaraKoltuk(_ sender: Any) {
        if uye?.uyelikTipi() == "VIP" {
            selectedKoltukNo = 2
        } else {
            showVIPAlert()
        }
    }
    
    @IBAction func ucNumaraKoltuk(_ sender: Any) {
        if uye?.uyelikTipi() == "VIP" {
            selectedKoltukNo = 3
        } else {
            showVIPAlert()
        }
    }
    
    @IBAction func dortNumaraKoltuk(_ sender: Any) {
        if uye?.uyelikTipi() == "VIP" {
            selectedKoltukNo = 4
        } else {
            showVIPAlert()
        }
    }
    
    @IBAction func besNumaraKoltuk(_ sender: Any) {
        selectedKoltukNo = 5
    }
    
    @IBAction func altiNumaraKoltuk(_ sender: Any) {
        selectedKoltukNo = 6
    }
    
    @IBAction func yediNumaraKoltuk(_ sender: Any) {
        selectedKoltukNo = 7
    }
    
    @IBAction func sekizNumaraKoltuk(_ sender: Any) {
        selectedKoltukNo = 8
    }
    
    @IBAction func dokuzNumaraKoltuk(_ sender: Any) {
        selectedKoltukNo = 9
    }
    
    @IBAction func onNumaraKoltuk(_ sender: Any) {
        selectedKoltukNo = 10
    }
    
    @IBAction func odemeYapp(_ sender: Any) {
        guard let koltukNo = selectedKoltukNo else { return }
        
        if let user = Auth.auth().currentUser, let ucus = ucus {
            kontrolEtVeSatinAlKoltuk(for: ucus, koltukNo: koltukNo, kullaniciBilgisi: user.uid)
        } else {
            print("Kullanıcı oturum açmamış veya uçuş seçilmemiş")
        }
    }
    
    @IBAction func rezerveEt(_ sender: Any) {
        guard let koltukNo = selectedKoltukNo else { return }
        
        if let user = Auth.auth().currentUser, let ucus = ucus {
            kontrolEtVeRezerveKoltuk(for: ucus, koltukNo: koltukNo, kullaniciBilgisi: user.uid)
        } else {
            print("Kullanıcı oturum açmamış veya uçuş seçilmemiş")
        }
    }
    

    func kontrolEtVeRezerveKoltuk(for flight: UcusClass, koltukNo: Int, kullaniciBilgisi: String) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        db.collection("biletler")
            .whereField("koltukNo", isEqualTo: koltukNo)
            .whereField("ucusNo", isEqualTo: flight.ucusKodu)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Bilet kontrol hatası: \(error)")
                } else if let snapshot = snapshot, !snapshot.isEmpty {
                    self.showAlreadyBuyAlert()
                } else {
                    db.collection("rezervasyonlar")
                        .whereField("koltukNo", isEqualTo: koltukNo)
                        .whereField("ucusBilgisi", isEqualTo: flight.ucusKodu)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("Rezervasyon kontrol hatası: \(error)")
                            } else if let snapshot = snapshot, !snapshot.isEmpty {
                                self.showAlreadyReservedAlert()
                            } else {
                                self.rezerveKoltuk(for: flight, koltukNo: koltukNo, kullaniciBilgisi: kullaniciBilgisi)
                            }
                        }
                }
            }
    }


    func kontrolEtVeSatinAlKoltuk(for flight: UcusClass, koltukNo: Int, kullaniciBilgisi: String) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        db.collection("rezervasyonlar")
            .whereField("koltukNo", isEqualTo: koltukNo)
            .whereField("ucusBilgisi", isEqualTo: flight.ucusKodu)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Rezervasyon kontrol hatası: \(error)")
                } else if let snapshot = snapshot, !snapshot.isEmpty {
                    self.showAlreadyReservedAlert()
                } else {
                    db.collection("biletler")
                        .whereField("koltukNo", isEqualTo: koltukNo)
                        .whereField("ucusNo", isEqualTo: flight.ucusKodu)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("Bilet kontrol hatası: \(error)")
                            } else if let snapshot = snapshot, !snapshot.isEmpty {
                                self.showAlreadyBuyAlert()
                            } else {
                                self.performSegue(withIdentifier: "toOdemeVC", sender: nil)
                            }
                        }
                }
            }
    }


    
    func rezerveKoltuk(for flight: UcusClass, koltukNo: Int, kullaniciBilgisi: String) {
        let rezervasyonBaslangic = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let rezervasyonTarihiString = dateFormatter.string(from: rezervasyonBaslangic)
        
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        if let userId = user?.uid {
            db.collection("rezervasyonlar").addDocument(data: [
                "kullaniciBilgisi": kullaniciBilgisi,
                "ucusBilgisi": flight.ucusKodu,
                "koltukNo": koltukNo,
                "rezervasyonTarihi": rezervasyonTarihiString,
                "kullaniciMail" : user?.email
            ]) { err in
                if let err = err {
                    print("Rezervasyon ekleme hatası: \(err)")
                } else {
                    print("Rezervasyon başarılı")
                    self.performSegue(withIdentifier: "toRezerveEt", sender: nil)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
            self.rezervasyonuKontrolEt(for: flight, koltukNo: koltukNo)
        }
    }
    
    func rezervasyonuKontrolEt(for flight: UcusClass, koltukNo: Int) {
        let db = Firestore.firestore()
        let rezervasyonDoc = db.collection("rezervasyonlar").document("\(flight.ucusKodu)_\(koltukNo)")
        
        rezervasyonDoc.getDocument { (document, error) in
            if let document = document, document.exists,
               let data = document.data(),
               let rezervasyonTarihiString = data["rezervasyonTarihi"] as? String {
               
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let rezervasyonBaslangic = dateFormatter.date(from: rezervasyonTarihiString) {
                    let currentTime = Date()
                    let diffMinutes = Calendar.current.dateComponents([.minute], from: rezervasyonBaslangic, to: currentTime).minute ?? 0
                    if diffMinutes >= 2 {
                        rezervasyonDoc.updateData([
                            "rezervasyonDurumu": false,
                            "kullaniciBilgisi": ""
                        ]) { err in
                            if let err = err {
                                print("Rezervasyon iptal etme hatası: \(err)")
                            } else {
                                print("Rezervasyon süresi doldu ve iptal edildi")
                            }
                        }
                    }
                } else {
                    print("Rezervasyon başlangıç tarihi dönüştürülemedi")
                }
            } else {
                print("Rezervasyon bulunamadı veya dönüştürülemedi")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOdemeVC" {
            if let destinationVC = segue.destination as? BiletSatinAlViewController {
                destinationVC.ucus = ucus
                destinationVC.selectedKoltukNo = selectedKoltukNo
            }
        }
    }
    
    func showVIPAlert() {
        let alert = UIAlertController(title: "VIP Üyelik Gerekli", message: "Bu koltuğu rezerve etmek için VIP üye olmanız gerekmektedir.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlreadyReservedAlert() {
        let alert = UIAlertController(title: "Koltuk Rezerve Edilmiş", message: "Bu koltuk zaten rezerve edilmiştir. Lütfen başka bir koltuk seçiniz.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlreadyBuyAlert() {
        let alert = UIAlertController(title: "Koltuk Satın Alınmış", message: "Bu koltuk zaten satın alınmıştır. Lütfen başka bir koltuk seçiniz.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
