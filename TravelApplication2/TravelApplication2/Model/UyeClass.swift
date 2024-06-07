//
//  UyeClass.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import Foundation

class UyeClass{
    var ad: String
    var soyad: String
    var email: String
    var sifre: String
    var uyelikTarihi: Date // Kayıt yılı
    var yillikAlinanBilet: [Int] // Her yıl alınan bilet sayısı
    
    init(ad: String, soyad: String, email: String, sifre: String, uyelikTarihi: Date, yillikAlinanBilet: [Int]) {
        self.ad = ad
        self.soyad = soyad
        self.email = email
        self.sifre = sifre
        self.uyelikTarihi = uyelikTarihi
        self.yillikAlinanBilet = yillikAlinanBilet
    }
    
      func uyelikTipi() -> String {
          let calendar = Calendar.current
          let currentDate = Date()
          
          // Kayıt tarihinden itibaren 10 yıl geçmiş ve her yıl en az dört bilet alınmışsa VIP üyedir
       if let registrationYearsAgo = calendar.date(byAdding: .year, value: -10, to: currentDate),
             uyelikTarihi <= registrationYearsAgo {
              var minBiletSayisi = true
              let yearsSinceRegistration = calendar.dateComponents([.year], from: uyelikTarihi, to: currentDate).year ?? 0
              
              for i in 0..<yearsSinceRegistration {
                  if i < yillikAlinanBilet.count && yillikAlinanBilet[i] < 4 {
                      minBiletSayisi = false
                      break
                  }
              }
              if minBiletSayisi {
                  return "VIP"
              }
          }
          
          // Kayıt tarihinden itibaren 5 yıl geçmiş ve her yıl en az bir bilet alınmışsa Daimi üyedir
          if let registrationYearsAgo = calendar.date(byAdding: .year, value: -5, to: currentDate),
             uyelikTarihi <= registrationYearsAgo {
              var minBiletAlma = true
              
              for i in 0..<yillikAlinanBilet.count {
                  if yillikAlinanBilet[i] < 1 {
                      minBiletAlma = false
                      break
                  }
              }
              if minBiletAlma {
                  return "Daimi"
              }
          }
          // Yukarıdaki koşulların hiçbiri sağlanmıyorsa Normal üyedir
          return "Normal"
      }
}
       

// Normal üye alt sınıfı
class NormalUye: UyeClass {
    override func uyelikTipi() -> String {
        return "Normal"
    }
}

// Daimi üye alt sınıfı
class DaimiUye: UyeClass {
    override func uyelikTipi() -> String {
        let membershipType = super.uyelikTipi() // Ana sınıftan fonksiyonu çağırır
              if membershipType == "Daimi" {
                  return "Daimi"
              } else {
                  return "Normal"
              }
    }
}

// VIP üye alt sınıfı
class VipUye: UyeClass {
    override func uyelikTipi() -> String {
        let membershipType = super.uyelikTipi() // Ana sınıftan fonksiyonu çağırır
               if membershipType == "VIP" {
                   return "VIP"
               } else {
                   return "Normal"
               }
    }
}

