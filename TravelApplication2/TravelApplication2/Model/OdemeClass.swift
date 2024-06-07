//
//  OdemeClass.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import Foundation

class OdemeClass {
    var odemeMiktari : Int
    var odemeTarihi : String
    var kartAdSoyad : String
    var kartNo : String
    var SKT : Int
    var CVV : Int
    
    init(odemeMiktari: Int, odemeTarihi: String, kartAdSoyad: String, kartNo: String, SKT: Int, CVV: Int) {
        self.odemeMiktari = odemeMiktari
        self.odemeTarihi = odemeTarihi
        self.kartAdSoyad = kartAdSoyad
        self.kartNo = kartNo
        self.SKT = SKT
        self.CVV = CVV
    }
    

}
