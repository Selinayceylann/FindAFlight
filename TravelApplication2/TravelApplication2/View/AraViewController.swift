//
//  AraViewController.swift
//  TravelApplication2
//
//  Created by selinay ceylan on 22.05.2024.
//

import UIKit

class AraViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var neredenNereyeText: UITextView!
    @IBOutlet weak var nereyeText: UITextField!
    @IBOutlet weak var neredenText: UITextField!
    @IBOutlet weak var tarihField: UITextField!
    @IBOutlet weak var planeImage2: UIImageView!
    @IBOutlet weak var tarihText: UITextView!
    @IBOutlet weak var planeImage1: UIImageView!
 
    var data = ["Ankara", "Antalya", "Çanakkale", "Gaziantep", "İstanbul", "İzmir",   "Trabzon", "Van"]
    var nonCanakkaleTrabzonData = ["Ankara", "Antalya", "Gaziantep", "İstanbul", "İzmir", "Van"]
    var nonCanakkaleVanData = ["Ankara", "Antalya", "Gaziantep", "İstanbul", "İzmir",   "Trabzon"]
    var nonTrabzonVanData = ["Ankara", "Antalya", "Çanakkale", "Gaziantep", "İstanbul", "İzmir"]
    var nonTrabzonCanakkaleVan = ["Ankara", "Antalya", "Gaziantep", "İstanbul", "İzmir"]

    var selectedCities: [String] = []
    
    let pickerVieww = UIPickerView()
    let pickerView2 = UIPickerView()
    let datePicker = UIDatePicker()
    
    var neredenSelectedCity: String?
    var nereyeSelectedCity: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tarihText.layer.cornerRadius = 10
        tarihText.clipsToBounds = true
        
        neredenNereyeText.layer.cornerRadius = 10
        neredenNereyeText.clipsToBounds = true
        
        pickerVieww.delegate = self
        pickerVieww.dataSource = self
        
        pickerView2.delegate = self
        pickerView2.dataSource = self
        
        neredenText.delegate = self
        nereyeText.delegate = self
                
        neredenText.inputView = pickerVieww
        nereyeText.inputView = pickerView2
        
        createDatePicker()
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        neredenText.inputAccessoryView = toolbar
        nereyeText.inputAccessoryView = toolbar
        
        // İlk seçim için şehir listesini güncelle
        selectedCities = data
        pickerVieww.reloadAllComponents()
        pickerView2.reloadAllComponents()
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        updateCities(for: sender.date)
    }
    
    func updateCities(for date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let weekday = components.weekday
        
        switch weekday {
        case 2: // Pazartesi
            selectedCities = nonTrabzonVanData
        case 5: // Perşembe
            selectedCities = nonCanakkaleTrabzonData
        case 7: // Cumartesi
            selectedCities = nonCanakkaleVanData
        default:
            selectedCities = nonTrabzonCanakkaleVan
        }
        
        // Mevcut seçilen şehirleri kontrol et
        var availableCities = selectedCities
        if let neredenCity = neredenSelectedCity, let index = availableCities.firstIndex(of: neredenCity) {
            availableCities.remove(at: index)
        }
        if let nereyeCity = nereyeSelectedCity, let index = availableCities.firstIndex(of: nereyeCity) {
            availableCities.remove(at: index)
        }
        
        pickerVieww.reloadAllComponents()
        pickerView2.reloadAllComponents()
    }
    
    @IBAction func araClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSeyahatlerVC", sender: nil)
    }
    
    func createDatePicker() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, doneBtn], animated: true)
        
        tarihField.inputAccessoryView = toolBar
        tarihField.inputView = datePicker
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        tarihField.text = formatter.string(from: datePicker.date)
        updateCities(for: datePicker.date)
        
        neredenText.isUserInteractionEnabled = true
        nereyeText.isUserInteractionEnabled = true
        
        self.view.endEditing(true)
    }
    
    @objc func doneButtonTapped() {
        neredenText.resignFirstResponder()
        nereyeText.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == neredenText || textField == nereyeText {
            if tarihField.text?.isEmpty ?? true {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSeyahatlerVC" {
            if let destinationVC = segue.destination as? SecimViewController {
                destinationVC.departureCity = neredenSelectedCity
                destinationVC.destinationCity = nereyeSelectedCity
                destinationVC.travelDate = datePicker.date
            }
        }
    }
}

extension AraViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerVieww {
            return selectedCities.count - (nereyeSelectedCity != nil ? 1 : 0)
        } else {
            return selectedCities.count - (neredenSelectedCity != nil ? 1 : 0)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerVieww {
            var cities = selectedCities
            if let nereyeCity = nereyeSelectedCity, let index = cities.firstIndex(of: nereyeCity) {
                cities.remove(at: index)
            }
            return cities[row]
        } else {
            var cities = selectedCities
            if let neredenCity = neredenSelectedCity, let index = cities.firstIndex(of: neredenCity) {
                cities.remove(at: index)
            }
            return cities[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerVieww {
            var cities = selectedCities
            if let nereyeCity = nereyeSelectedCity, let index = cities.firstIndex(of: nereyeCity) {
                cities.remove(at: index)
            }
            neredenText.text = cities[row]
            neredenSelectedCity = cities[row]
        } else {
            var cities = selectedCities
            if let neredenCity = neredenSelectedCity, let index = cities.firstIndex(of: neredenCity) {
                cities.remove(at: index)
            }
            nereyeText.text = cities[row]
            nereyeSelectedCity = cities[row]
        }
        
        updateCities(for: datePicker.date)
    }
}
