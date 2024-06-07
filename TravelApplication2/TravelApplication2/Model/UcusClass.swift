//
//  UcusClass.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import Foundation


class UcusClass {
    var ucusKodu: Int
    var kalkisTarihi: String
    var nereden: String
    var nereye: String
    var kalkisSaati: String
    var varisSaati: String
    var ucakTipi: String
    var ucak: UcakClass?
    var bilett : [BiletClass?]
    var ucret: Int
    var sure: String
    var rezervasyonlar: [RezervasyonClass] = []

    init(ucusKodu: Int, kalkisTarihi: String, nereden: String, nereye: String, kalkisSaati: String, varisSaati: String, ucakTipi: String, ucak: UcakClass? = nil, bilett: [BiletClass?], ucret: Int, sure: String) {
        self.ucusKodu = ucusKodu
        self.kalkisTarihi = kalkisTarihi
        self.nereden = nereden
        self.nereye = nereye
        self.kalkisSaati = kalkisSaati
        self.varisSaati = varisSaati
        self.ucakTipi = ucakTipi
        self.ucak = ucak
        self.bilett = bilett
        self.ucret = ucret
        self.sure = sure
    }

}


