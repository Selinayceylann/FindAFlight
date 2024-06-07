import UIKit
import FirebaseAuth
import FirebaseFirestore

class BiletSatinAlViewController: UIViewController {
    
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var sktField: UITextField!
    @IBOutlet weak var kartNoField: UITextField!
    @IBOutlet weak var ucretXxx: UILabel!
    @IBOutlet weak var kartAdSoyadField: UITextField!
    @IBOutlet weak var koltukNo: UILabel!
    @IBOutlet weak var kalkisSaati: UILabel!
    @IBOutlet weak var hatBilgileri: UILabel!
    
    var ucus: UcusClass?
    var selectedKoltukNo: Int?
    var uye : UyeClass?
    
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
        
        fetchUserData { [weak self] in
            self?.updateUI()
        }
    }
    
    func fetchUserData(completion: @escaping () -> Void) {
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
            completion()
        }
    }
    
    
    func updateUI() {
        guard let ucus = ucus, let selectedKoltukNo = selectedKoltukNo else { return }
        let user = Auth.auth().currentUser
        let biletUcret = ucus.ucret
        // Üyelik tipine göre indirim hesaplama
        let bilet: BiletClass
        switch uye?.uyelikTipi() {
        case "VIP":
            bilet = VIPBilet(ucusNo: ucus.ucusKodu, koltukNo: selectedKoltukNo, Ucret: biletUcret, kalkisNoktasi: ucus.nereden, varisNoktası: ucus.nereye, ucusTarihi: ucus.kalkisTarihi, uye: uye, email: (user?.email)!)
        case "Daimi":
            bilet = DaimiBilet(ucusNo: ucus.ucusKodu, koltukNo: selectedKoltukNo, Ucret: biletUcret, kalkisNoktasi: ucus.nereden, varisNoktası: ucus.nereye, ucusTarihi: ucus.kalkisTarihi, uye: uye, email: (user?.email)!)
        default:
            bilet = NormalBilet(ucusNo: ucus.ucusKodu, koltukNo: selectedKoltukNo, Ucret: biletUcret, kalkisNoktasi: ucus.nereden, varisNoktası: ucus.nereye, ucusTarihi: ucus.kalkisTarihi, uye: uye, email: (user?.email)!)
        }
        
        
        let indirimliFiyat = Double(bilet.Ucret) 
        let formattedString = String(format: "Bilet Ücreti: %.2f TL", indirimliFiyat)
        ucretXxx.text = formattedString
        koltukNo.text = "Koltuk No: \(selectedKoltukNo)"
        kalkisSaati.text = "Kalkış Saati \(ucus.kalkisSaati)"
        hatBilgileri.text = "Hat Bilgileri : \(ucus.nereden) -> \(ucus.nereye)"
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func satinAl(_ sender: Any) {
        guard let kartNo = kartNoField.text, !kartNo.isEmpty,
              let kartAdSoyad = kartAdSoyadField.text, !kartAdSoyad.isEmpty,
              let sktText = sktField.text, let skt = Int(sktText),
              let cvvText = cvvField.text, let cvv = Int(cvvText),
              let ucretText = ucretXxx.text?.replacingOccurrences(of: "Bilet Ücreti: ", with: "").replacingOccurrences(of: " TL", with: ""),
              let odemeMiktari = Double(ucretText) else {
            print("Lütfen tüm alanları doldurun")
            return
        }
        
        
        let odemeTarihi = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let odemeTarihiString = dateFormatter.string(from: odemeTarihi)
        
        let odeme = OdemeClass(odemeMiktari: Int(odemeMiktari), odemeTarihi: odemeTarihiString, kartAdSoyad: kartAdSoyad, kartNo: kartNo, SKT: skt, CVV: cvv)
        
        
        let user = Auth.auth().currentUser
        
        // Yıllık alınan bilet sayısını güncelle
        if let uye = uye {
            let currentYear = Calendar.current.component(.year, from: Date())
            let membershipYear = Calendar.current.component(.year, from: uye.uyelikTarihi)
            let yearIndex = currentYear - membershipYear
            
            if yearIndex < uye.yillikAlinanBilet.count {
                uye.yillikAlinanBilet[yearIndex] += 1
            } else {
                // Eğer yeni bir yıl ise, diziye yeni bir eleman ekle
                for _ in uye.yillikAlinanBilet.count...yearIndex {
                    uye.yillikAlinanBilet.append(0)
                }
                uye.yillikAlinanBilet[yearIndex] = 1
            }

            
            // Üyelik tipine göre bilet oluşturma
            let bilet: BiletClass
            switch uye.uyelikTipi() {
            case "VIP":
                bilet = VIPBilet(ucusNo: ucus!.ucusKodu, koltukNo: selectedKoltukNo!, Ucret: ucus!.ucret, kalkisNoktasi: ucus!.nereden, varisNoktası: ucus!.nereye, ucusTarihi: ucus!.kalkisTarihi, uye: uye, odeme: odeme, email: (user?.email)!)
            case "Daimi":
                bilet = DaimiBilet(ucusNo: ucus!.ucusKodu, koltukNo: selectedKoltukNo!, Ucret: ucus!.ucret, kalkisNoktasi: ucus!.nereden, varisNoktası: ucus!.nereye, ucusTarihi: ucus!.kalkisTarihi, uye: uye, odeme: odeme, email: (user?.email)!)
            default:
                bilet = NormalBilet(ucusNo: ucus!.ucusKodu, koltukNo: selectedKoltukNo!, Ucret: ucus!.ucret, kalkisNoktasi: ucus!.nereden, varisNoktası: ucus!.nereye, ucusTarihi: ucus!.kalkisTarihi, uye: uye, odeme: odeme, email: (user?.email)!)
            }
            
            // Bileti Firestore'a kaydet
            let db = Firestore.firestore()
            if let userId = user?.uid {
                db.collection("biletler").addDocument(data: [
                    "ucusNo": bilet.ucusNo,
                    "koltukNo": bilet.koltukNo,
                    "ucret": bilet.Ucret,
                    "kalkisNoktasi": bilet.kalkisNoktasi,
                    "varisNoktasi": bilet.varisNoktası,
                    "ucusTarihi": bilet.ucusTarihi,
                    "odemeMiktari": odeme.odemeMiktari,
                    "odemeTarihi": odeme.odemeTarihi,
                    "kartAdSoyad": odeme.kartAdSoyad,
                    "kartNo": odeme.kartNo,
                    "SKT": odeme.SKT,
                    "kullaniciMail": user?.email,
                    "CVV": odeme.CVV
                ]) { err in
                    if let err = err {
                        print("Bilet kaydedilemedi: \(err)")
                    } else {
                        print("Bilet başarıyla kaydedildi!")
                    }
                }
                // Güncellenmiş yıllık alınan bilet sayısını Firestore'da güncelle
                db.collection("uyeler").document(userId).updateData([
                    "yillikAlinanBilet": uye.yillikAlinanBilet
                ]) { err in
                    if let err = err {
                        print("Yıllık alınan bilet sayısı güncellenemedi: \(err)")
                    } else {
                        print("Yıllık alınan bilet sayısı başarıyla güncellendi!")
                    }
                }
            }
            
            
            print("Ödeme başarıyla yapıldı ve bilet alındı")  // Hata ayıklama için
            performSegue(withIdentifier: "toGosterVC", sender: self)
        }
        
        
    }
}
