//
//  RegistrationViewController.swift
//  IosChatt
//
//  Created by Marcus Nilsson on 2021-05-17.
//

import UIKit
import FirebaseAuth
import Firebase

class RegistrationViewController: UIViewController {
    @IBOutlet weak var registerEmailTextfield: UITextField!
    @IBOutlet weak var registerUsernameTextfield: UITextField!
    @IBOutlet weak var registerPasswordTextfield: UITextField!
    @IBOutlet weak var errorLable: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func validateFields() -> String? {
        //check that all field is filled in
        if registerEmailTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || registerUsernameTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            registerPasswordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all the required fields"
            
        }
        
        //check if password is secure
        let cleanedPassword = registerPasswordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "please make sure your password is at least 8 charecters, contains a special charecter and a number"
        }
        
        return nil
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        //validate fields
        let error = validateFields()
        
        if error != nil {
            showError(message: error!)
        } else {
            
            //create cleaned versions of the data
            let email = registerEmailTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let userName = registerUsernameTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = registerPasswordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //create the user
            Auth.auth().createUser(withEmail: email, password: password) { result, err in
                if err != nil {
                    self.showError(message: err!.localizedDescription)
                    
                } else {
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["username":userName, "uid": result!.user.uid]) { error in
                        
                        if error != nil {
                            self.showError(message: "Error saving user data")
                        }
                    }
                    
                    //Transision to chatView
                    self.goToChatScreen()
                }
            }
        }
    }
    func showError(message:String) {
        errorLable.text = message
        errorLable.alpha = 1
    }
    func goToChatScreen() {
        
        //self.performSegue(withIdentifier: "toHomeVC", sender: self)
        
        let homeViewController = storyboard?.instantiateViewController(identifier: "loginVC")
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
}
