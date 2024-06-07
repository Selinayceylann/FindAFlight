import UIKit
import FirebaseAuth
import FirebaseFirestore

class RezervasyonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var rezervasyonlar: [RezervasyonClass] = []
    var timers: [String: Timer] = [:]
    var remainingTimes: [String: Int] = [:] // "ucusNo_koltukNo" -> Kalan Süre (saniye)

    @IBOutlet weak var tableViewRez: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewRez.delegate = self
        tableViewRez.dataSource = self
        
        // Kullanıcı oturum açtıysa Firebase Authentication'dan kullanıcı bilgilerini al
        fetchUcuslar()
    }
    
    @objc func handleRezervasyonGuncellendi() {
        tableViewRez.reloadData()
        setupTimers() // Timers'ı yeniden başlatmak ve güncel zamanları almak için
    }

    func setupTimers() {
        let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
               
               for rezervasyon in rezervasyonlar {
                   if let rezervasyonTarihi = dateFormatter.date(from: rezervasyon.rezervasyonTarihi) {
                       let remainingTime = 120 - Int(Date().timeIntervalSince(rezervasyonTarihi))
                       let key = "\(rezervasyon.ucusBilgisi)_\(rezervasyon.koltukNo)"
                       remainingTimes[key] = remainingTime
                       startTimer(for: key)
                   } else {
                       print("Rezervasyon tarihi dönüştürülemedi")
                   }
               }
    }

    func fetchUcuslar() {
        let db = Firestore.firestore()
        // Kullanıcının UID'sine sahip belirli bir koleksiyondan uçuşlarını çek
        let user = Auth.auth().currentUser
        if let userId = Auth.auth().currentUser?.uid {
            db.collection("rezervasyonlar")
                .whereField("kullaniciMail", isEqualTo: user?.email)
                .getDocuments { snapshot, error in
                if let error = error {
                    print("Uçuşlar çekilemedi: \(error)")
                } else {
                    self.rezervasyonlar.removeAll()
                    for document in snapshot!.documents {
                        let data = document.data()
                        let rezervasyon = RezervasyonClass(kullaniciBilgisi: data["kullaniciBilgisi"] as! String, ucusBilgisi: data["ucusBilgisi"] as! Int, koltukNo: data["koltukNo"] as! Int, rezervasyonTarihi: data["rezervasyonTarihi"] as! String, email: (user?.email)!)
                        self.rezervasyonlar.append(rezervasyon)
                    }
                    self.tableViewRez.reloadData()
                    self.setupTimers()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewRez.dequeueReusableCell(withIdentifier: "rezerv", for: indexPath) as! RezervasyonTableViewCell
        let rezervasyon = rezervasyonlar[indexPath.row]
        let key = "\(rezervasyon.ucusBilgisi)_\(rezervasyon.koltukNo)"
        
        if let remainingTime = remainingTimes[key] {
            let minutes = remainingTime / 60
            let seconds = remainingTime % 60
            cell.kalanSureRez.text = String(format: "%02d:%02d", minutes, seconds)
        } else {
            cell.kalanSureRez.text = "Süre doldu"
        }
        
        cell.koltukNoRez.text = "Koltuk No: \(rezervasyon.koltukNo)"
        cell.neredenRez.text = "Uçuş No: \(rezervasyon.ucusBilgisi)"
        cell.tarihRez.text = "Rezerve Tarihi: \(rezervasyon.rezervasyonTarihi)"
        // Closure ile iptal butonuna fonksiyon atama
        cell.iptalAction = { [weak self] in
            self?.iptalRezervasyon(ucusBilgisi: rezervasyon.ucusBilgisi, koltukNo: rezervasyon.koltukNo)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rezervasyonlar.count
    }
    
    func startTimer(for key: String) {
        timers[key]?.invalidate()
              timers[key] = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                  if let remainingTime = self.remainingTimes[key] {
                      if remainingTime > 0 {
                          self.remainingTimes[key]! -= 1
                          if let index = self.rezervasyonlar.firstIndex(where: { "\( $0.ucusBilgisi)_\($0.koltukNo)" == key }) {
                              let indexPath = IndexPath(row: index, section: 0)
                              self.tableViewRez.reloadRows(at: [indexPath], with: .none)
                          }
                      } else {
                          timer.invalidate()
                          if let rezervasyonIndex = self.rezervasyonlar.firstIndex(where: { "\( $0.ucusBilgisi)_\($0.koltukNo)" == key }) {
                              self.rezervasyonlar.remove(at: rezervasyonIndex)
                              self.remainingTimes[key] = nil
                              self.updateRezervasyonDurumu(ucusBilgisi: Int(key.split(separator: "_")[0])!, koltukNo: Int(key.split(separator: "_")[1])!)
                              print("Rezervasyon süresi doldu ve iptal edildi")
                              self.tableViewRez.reloadData()
                          }
                      }
                  }
              }
    }
    
    func updateRezervasyonDurumu(ucusBilgisi: Int, koltukNo: Int) {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        if let userId = user?.uid {
           db.collection("rezervasyonlar")
                .whereField("ucusBilgisi", isEqualTo: ucusBilgisi)
                .whereField("koltukNo", isEqualTo: koltukNo)
                .whereField("kullaniciMail", isEqualTo: user?.email)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Rezervasyon güncelleme hatası: \(error)")
                } else {
                    for document in snapshot!.documents {
                        document.reference.delete {  err in
                            if let err = err {
                                print("Rezervasyon silme hatası: \(err)")
                            } else {
                                print("Rezervasyon başarıyla güncellendi")

                            }
                        }
                    }
                }
            }
        }
    }

    func iptalRezervasyon(ucusBilgisi: Int, koltukNo: Int) {
        let key = "\(ucusBilgisi)_\(koltukNo)"
               if let rezervasyonIndex = rezervasyonlar.firstIndex(where: { "\( $0.ucusBilgisi)_\($0.koltukNo)" == key }) {
                   rezervasyonlar.remove(at: rezervasyonIndex)
                   remainingTimes[key] = nil
                   timers[key]?.invalidate()
                   timers[key] = nil
                   updateRezervasyonDurumu(ucusBilgisi: ucusBilgisi, koltukNo: koltukNo)
                   tableViewRez.reloadData()
                   print("Rezervasyon iptal edildi")
               }
    }
}
