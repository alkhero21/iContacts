//
//  ViewController.swift
//  iContacts
//
//  Created by Alibek Allamzharov on 02.07.2023.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    static let contactKey: String = "userContacts"
    
    var allContactsArrayOfDictionaries: [[String:Any]] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        getAllContacts()
        
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "cellIdentifier")
        tableView.dataSource = self
        tableView.rowHeight = 46
        
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(getAllContacts), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAllContacts()
    }
    
    func addContactAlert() {
        let alertController = UIAlertController(title: "AddContact", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "First name"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Last name"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Phone number"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let firstName: String = alertController.textFields![0].text, !firstName.isEmpty else {
                self.showErrorAlert(message: "First name is Empty")
                return
            }
            guard let lastName: String = alertController.textFields![1].text, !lastName.isEmpty else {
                self.showErrorAlert(message: "Last name is Empty")
                return
            }
            guard let phone: String = alertController.textFields![2].text, !phone.isEmpty else {
                self.showErrorAlert(message: "Phone number is invalid")
                return
            }
            
            guard phone.isValidPhoneNumber() else {
                self.showErrorAlert(message: "Phone number is invalid")
                return
            }
            

            self.add(name: firstName, lastName: lastName, phone: phone)
        }
        alertController.addAction(addAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func showErrorAlert(message: String) {
        let errorAlertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default)
        errorAlertController.addAction(okAction)
        present(errorAlertController, animated: true)
    }
    
    func add(name: String, lastName: String, phone: String) {
        let userContacts: [String: Any] = ["firstName": name, "lastName": lastName, "phone": phone]
        let userContactsArray: [[String: Any]] = getAllContactsArray() + [userContacts]
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(userContactsArray, forKey: ViewController.contactKey)
    }
    
    @objc func getAllContacts() {
        let userDefaults = UserDefaults.standard
        
        guard let allContacts = UserDefaults.standard.array(forKey: ViewController.contactKey) else {
            print("UserDefaults doesn't contain array with key: userContacts")
            return
        }
        
        guard let allContactsArrayOfDictionaries = allContacts as? [[String:Any]] else {
            print("Couldn't convert Any to [[String:Any]]")
            return
        }
        tableView.refreshControl?.endRefreshing()
        self.allContactsArrayOfDictionaries = allContactsArrayOfDictionaries


    }
    
    func getAllContactsArray() -> [[String:Any]] {
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: ViewController.contactKey) as? [[String:Any]]
        return array ?? []
    }
    
    @IBAction func addUserAction(_ sender: Any) {
        addContactAlert()
    }
    
    func getSingleContactUser(index: Int) -> String? {
        let dictionary:[String: Any] = allContactsArrayOfDictionaries[index]
        
        guard let firstName = dictionary["firstName"] as? String, let secondName = dictionary["lastName"] as? String  else{
            return nil
        }
        
        let text = "\(firstName) \(secondName)"
        return text
    }
    
    
    
}


extension String {
    
    // Возвращает 'true' если номер телефона валидный, 'false' в ином случае
    func isValidPhoneNumber() -> Bool {
        
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        
        return phoneCheck.evaluate(with: self)
    }
}

// MARK: UITableViewDataSourse & UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allContactsArrayOfDictionaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! ContactTableViewCell
        
        cell.contactTextLabel.text = getSingleContactUser(index: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ContactViewController()
        viewController.text = getSingleContactUser(index: indexPath.row)
        navigationController?.pushViewController(viewController, animated: true)
    }
}







