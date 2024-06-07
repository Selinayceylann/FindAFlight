import Foundation


class RezervasyonClass: Decodable {
    var kullaniciBilgisi: String
    var ucusBilgisi: Int
    var koltukNo: Int
    var rezervasyonTarihi: String
    var email: String

    init(kullaniciBilgisi: String, ucusBilgisi: Int, koltukNo: Int, rezervasyonTarihi: String, email: String) {
        self.kullaniciBilgisi = kullaniciBilgisi
        self.ucusBilgisi = ucusBilgisi
        self.koltukNo = koltukNo
        self.rezervasyonTarihi = rezervasyonTarihi
        self.email = email
    }

}
