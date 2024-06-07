//
//  BiletClass.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import Foundation

class BiletClass {
    var ucusNo : Int
    var koltukNo : Int
    var Ucret : Int
    var kalkisNoktasi : String
    var varisNoktası : String
    var ucusTarihi : String
    var uye : UyeClass?
    var odeme : OdemeClass?
    var email: String

    init(ucusNo: Int, koltukNo: Int, Ucret: Int, kalkisNoktasi: String, varisNoktası: String, ucusTarihi: String, uye: UyeClass? = nil, odeme: OdemeClass? = nil, email: String) {
        self.ucusNo = ucusNo
        self.koltukNo = koltukNo
        self.Ucret = Ucret
        self.kalkisNoktasi = kalkisNoktasi
        self.varisNoktası = varisNoktası
        self.ucusTarihi = ucusTarihi
        self.uye = uye
        self.odeme = odeme
        self.email = email
    }
    
    // İndirim miktarını hesaplayan fonksiyon, alt sınıflar tarafından override edilecek
    func indirimMiktari() -> Double {
           return 0
    }
    
}

// Normal bilet alt sınıfı
class NormalBilet: BiletClass {
    override func indirimMiktari() -> Double {
        return 0
    }
}

// VIP bilet alt sınıfı
class VIPBilet: BiletClass {
    override func indirimMiktari() -> Double {
       if let uye = uye as? VipUye {
           return Double(Ucret - Ucret*Int(0.25)) // VIP üyelere %25 indirim uygulanır
        } else {
            return 0 // VIP üye değilse indirim uygulanmaz
        }
    }
  }

// Daimi bilet alt sınıfı
class DaimiBilet: BiletClass {
    override func indirimMiktari() -> Double {
        let toplamBiletSayisi = uye?.yillikAlinanBilet.reduce(0, +)    // üyenin aldığı yıllık bilet sayıları
        
        if toplamBiletSayisi! >= 5 && toplamBiletSayisi! % 5 == 0 {
            return Double(Ucret - Ucret*Int(0.10)) // 5'in katı olan biletlerden sonraki biletler için %10 indirim uygulanır
        } 
        
        return 0
    }
}


