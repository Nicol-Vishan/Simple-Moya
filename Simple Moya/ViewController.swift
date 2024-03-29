//
//  ViewController.swift
//  Simple Moya
//
//  Created by Nicol Vishan on 04/10/21.
//

import UIKit
import Moya

class ViewController: UIViewController {

    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var tableViewUser: UITableView!

    var users = [User]()
    let provider = MoyaProvider<UserServices>()

    fileprivate func readUsers() -> Cancellable {
        return provider.request(.readUsers) { result in
            switch result {
            case .success(let response):
                do {
                    let userList = try JSONDecoder().decode([User].self, from: response.data)
                    self.users = userList
                    self.tableViewUser.reloadData()
                } catch (let error)  {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        readUsers()

    }
    
    func setupView() {
        btnRefresh.setImage(UIImage(named: "refresh"), for: .normal)
        btnRefresh.setTitle("", for: .normal)
        btnRefresh.backgroundColor = UIColor.clear
        btnRefresh.layer.cornerRadius = 25
        btnRefresh.translatesAutoresizingMaskIntoConstraints = false
        btnRefresh.widthAnchor.constraint(equalToConstant: 90).isActive = true
        btnRefresh.heightAnchor.constraint(equalToConstant: 90).isActive = true
        btnRefresh.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        btnRefresh.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant:  -10).isActive = true
    }

    @IBAction func pressedAddUser(_ sender: Any) {
        let newUser = User(id: 60, name: "Anjelo Mathews")
        provider.request(.createUser(name: newUser.name)) { result in
            switch result {
                case .success(let response):
                    do {
                        let newUser = try JSONDecoder().decode(User.self, from: response.data)
                        self.users.insert(newUser, at: 0)
                        self.tableViewUser.reloadData()
                    } catch let error {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    @IBAction func btnnRefresh(_ sender: Any) {
        btnRefresh.layoutIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.btnRefresh.transform = self.btnRefresh.transform.rotated(by: CGFloat.pi)
            self.readUsers()
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let users = users[indexPath.row]
        cell.textLabel?.text = users.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        provider.request(.updateUser(id: user.id, name: "Tim Cook")) { result in
            switch result {
                case .success(let response):
                    do {
                        let modifiedUser = try JSONDecoder().decode(User.self, from: response.data)
                        self.users[indexPath.row] = modifiedUser
                        self.tableViewUser.reloadData()
                    } catch let error {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let user = users[indexPath.row]
            provider.request(.deleteUser(id: user.id)) { result in
                switch result {
                    case.success(let response):
                        print("Delete: \(response)")
                        self.users.remove(at: indexPath.row)
                        self.tableViewUser.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }

}
