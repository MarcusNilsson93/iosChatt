//
//  LoginViewController.swift
//  IosChatt
//
//  Created by Marcus Nilsson on 2021-05-17.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        view.backgroundColor = .lightGray
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
    }
    
    @objc private func didTapRegister() {
        let vc = RegistrationViewController()
        vc.title = "Register an acount"
        navigationController?.pushViewController(vc, animated: true)
    }
    

    
}
