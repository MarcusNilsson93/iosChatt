//
//  ViewController.swift
//  IosChat
//
//  Created by Marcus Nilsson on 2021-05-26.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    private var usersCollectionRefrence: CollectionReference!
    private var searchUser = [User]()
    private var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        usersCollectionRefrence = Firestore.firestore().collection("users")
        self.navigationItem.setHidesBackButton(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usersCollectionRefrence.getDocuments { [self] snapshot, error in
            if ((error) != nil) {
                print(error!)
            } else {
                guard let snap = snapshot else {return}
                for document in snap.documents {
                    let data = document.data()
                    let userName = data["username"] as? String ?? "Anonymous"
                    let uid = data["uid"] as? String ?? "0"
                    
                    let newUser = User(userName, uid: uid)
                    print(newUser.uid)
                    if self.users.isEmpty && newUser.uid != Auth.auth().currentUser?.uid {
                        self.users.append(newUser)
                    } else if (!users.isEmpty && newUser.uid != Auth.auth().currentUser?.uid) {
                        if !self.users.contains(newUser) {
                            self.users.append(newUser)
                        }
                        
                    }
                }
            }
            self.tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as? CustomTableViewCell {
            cell.nameLable.text = users[indexPath.row].userName
            cell.accessoryType = .disclosureIndicator
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = users[indexPath.row]
        let vc = ChatViewController(user: selectedUser)
        vc.title = selectedUser.userName
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let auth = Auth.auth()
        do{
            try auth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
//            let loginViewController = (self.storyboard?.instantiateViewController(identifier: "loginVC"))! as LoginViewController
//            self.view.window?.rootViewController = loginViewController
//            self.view.window?.makeKeyAndVisible()
        } catch let signOutError {
            print(signOutError)
            
        }
                
    }
    
}
