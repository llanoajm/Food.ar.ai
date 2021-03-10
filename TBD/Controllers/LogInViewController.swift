//
//  LogInViewController.swift
//  TBD
//
//  Created by Antonio Llano on 15/02/21.
//

import UIKit
import Firebase

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    
    var user = ""
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    @IBAction func doneButtonPressed(_ sender: Any) {
        if let email = self.emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
              
                
                //[weak self] guard let self = self else { return }
                
                if let e = error{
                    
                    let alertController = UIAlertController(title: "Error", message: "\(e.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else{
                    //NAvigate to the chat view controller
                    
                    print("Logged In succesfully")
                    self.user = self.emailTextField.text!.emailToUsername(self.emailTextField.text!)
                    
                    self.defaults.removeObject(forKey: "user")
                    
                    self.defaults.set([self.user], forKey:"user")
                   
                    
                    
                    self.performSegue(withIdentifier: "signInToHome", sender: self)
                }
                
              // ...
                
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInToHome"{
            
//            let homeVC = segue.destination as! TabBarController
//            homeVC.user = self.user
           
            
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
