//
//  SignUpViewController.swift
//  TBD
//
//  Created by Antonio Llano on 15/02/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var dataManaging = DataManaging()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        dataManaging.delegate = self
        dataManaging.fetchData()
        dataManaging.postData()
        print("hey world")
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func signUpTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e.localizedDescription)
                    
                    let alertController = UIAlertController(title: "Error", message: "\(e.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else{
//                    if let email = Auth.auth().currentUser?.email{
                        
//                        self.db.collection("users").addDocument(data: ["email": email])
                    //NAvigate to the chat view controller
                    print("\(String(describing: self.emailTextField.text!))'s account succesfully created")
                          self.defaults.set(self.emailTextField.text, forKey: "accounts")
                    self.performSegue(withIdentifier: "signUpToHome", sender: self)
                    
//                }
                }
        }
        
        }

        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.portrait
    }
    
}
extension SignUpViewController: DataManagingDelegate{
    func didUpdateData(_ dataManaging: DataManaging, data: DataModel) {
        print(data.scanned_products[1][0], data.userIds[1], data.usernames[1])
        
        

    }
    
    func didFailWithError(error: Error) {
        print("the error is: \(error)")
    }
    
    
}
