//
//  LoginViewController.swift
//  IosChatt
//
//  Created by Marcus Nilsson on 2021-05-17.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var loginEmailTextfield: UITextField!
    @IBOutlet weak var loginPasswordTextfield: UITextField!
    @IBOutlet weak var errorLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func loginButtonAction(_ sender: Any) {
        //Validate Text Fields
        //Create cleaned versions of the text fields
        let email = loginEmailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = loginPasswordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //Sign in the user
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if error != nil {
                self.errorLable.text = error!.localizedDescription
                self.errorLable.alpha = 1
            } else {
                //let homeViewController = self.storyboard?.instantiateViewController(identifier: "HomeVC")
                //self.view.window?.rootViewController = homeViewController
                //self.view.window?.makeKeyAndVisible()
                self.performSegue(withIdentifier: "toHomeVC", sender: self)
                
            }
        }
    }
  //Prepare to send right token
}
