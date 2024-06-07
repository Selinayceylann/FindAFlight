import UIKit
import Firebase

class KatiyOlViewController: UIViewController {

    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func kayitOlButton(_ sender: Any) {
        if emailText.text != "" && passwordText.text != "" && usernameText.text != "" && surnameText.text != "" {
            
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { (authdata, error) in
                if error != nil {
                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                } else {
                    if let userId = authdata?.user.uid {
                        let db = Firestore.firestore()
                        db.collection("uyeler").document(userId).setData([
                            "ad": self.usernameText.text!,
                            "soyad": self.surnameText.text!,
                            "email": self.emailText.text!,
                            "uyelikTarihi": Timestamp(date: Date()),
                            "yillikAlinanBilet": [0], 
                            "bakiye": 0.0
                        ]) { error in
                            if let error = error {
                                print("Firestore'a veri eklenirken hata oluştu: \(error.localizedDescription)")
                            } else {
                                print("Kullanıcı başarıyla Firestore'a eklendi")
                                self.performSegue(withIdentifier: "toAraVC", sender: nil)
                            }
                        }
                    }
                }
            }
        } else {
            self.makeAlert(titleInput: "Error", messageInput: "Boş alanları doldurunuz!")
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}
