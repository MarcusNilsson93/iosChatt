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
        print("Detta är den inloggade profilen \(String(describing: Auth.auth().currentUser?.displayName))")


        // Do any additional setup after loading the view.
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
                    print(newUser.userName)
                    self.users.append(newUser)
                    
                }
                self.tableView.reloadData()
            }
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
        
        //print(selectedUser.userName)
        //let vc = ProfileViewController(user: selectedUser)
        //let navigationController = UINavigationController(rootViewController: vc)
        //navigationController.modalPresentationStyle = .fullScreen
        //vc.title = "Profile"
        //present(navigationController, animated: true)
        //self.performSegue(withIdentifier: "segueToProfile", sender: self)
        //vc.modalPresentationStyle = .fullScreen
        //vc.title = "Profile"
        //present(vc, animated: true)
        
        
        let vc = ChatViewController(user: selectedUser)
        vc.title = selectedUser.userName
        navigationController?.pushViewController(vc, animated: true)
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        if segue.identifier == "Profile" {
//            let profileVC = segue.destination as! ProfileViewController
//            let selectedRowIndex = self.tableView.indexPathForSelectedRow
//            profileVC.userName = users[selectedRowIndex!.row].userName
//
//        }
//    }
    

}
