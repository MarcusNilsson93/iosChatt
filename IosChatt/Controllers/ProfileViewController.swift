//
//  ProfileViewController.swift
//  IosChat
//
//  Created by Marcus Nilsson on 2021-05-28.
//

import UIKit

class ProfileViewController: UIViewController {
        
    private let user: User
    let lable = UILabel()
    
    init(user:User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action:nil)
        view.backgroundColor = .systemGreen
        lable.frame = CGRect(x: self.view.frame.width / 2, y: 100, width: 120, height: 120)
        lable.text = "\(user.userName)"
        lable.textColor = .black
        view.addSubview(lable)
        print("You have selected \(user.userName)")
        // Do any additional setup after loading the view.
    }

}
