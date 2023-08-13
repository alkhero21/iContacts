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
    
    
    
    var allContactsArrayOfDictionaries: [ContactGroup] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let contactManager = ContactManager()
    

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
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
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
            

            let contact = Contact(firstName: firstName, lastName: lastName, phone: phone)
            self.add(contact: contact)
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
    
    func add(contact:Contact) {
        contactManager.add(contact: contact)
//        let userContacts: [String: Any] = ["firstName": name, "lastName": lastName, "phone": phone]
//        let userContactsArray: [[String: Any]] = getAllContactsArray() + [userContacts]
//
//        let userDefaults = UserDefaults.standard
//        userDefaults.set(userContactsArray, forKey: ViewController.contactKey)
        self.getAllContacts()
    }
    
    @objc func getAllContacts() {
        
        tableView.refreshControl?.beginRefreshing()
        
        var dictionary: [String: [Contact]] = [:]
        
        let allContacts = contactManager.getAllContactsStruct()
        
        allContacts.forEach{ contact in
            var key: String!
            
            if segmentedControl.selectedSegmentIndex == 0 {
                key = String(contact.firstName.first!)
            }else if segmentedControl.selectedSegmentIndex == 1 {
                key = String(contact.lastName.first!)
            }
            
            if var existingContacts = dictionary[key] {
                existingContacts.append(contact)
                dictionary[key] = existingContacts
            }else {
                dictionary[key] = [contact]
            }
            
        }
        
        var arrayOfContactGroup: [ContactGroup] = []
        
        let alphabeticallyOrderedKeys: [String] = dictionary.keys.sorted { key1, key2 in
            return key1 < key2
        }
        
        alphabeticallyOrderedKeys.forEach { key in
            let contacts = dictionary[key]
            let contactGroup = ContactGroup(title: key, contacts: contacts!)
            arrayOfContactGroup.append(contactGroup)
        }
        
        
        tableView.refreshControl!.endRefreshing()
        self.allContactsArrayOfDictionaries = arrayOfContactGroup


    }
    
    // Извлечение контакта из массива arrayOfContactGroup
    func getContact(indexPath:IndexPath) -> Contact {
        let contactGroup = allContactsArrayOfDictionaries[indexPath.section]
        let contact = contactGroup.contacts[indexPath.row]
        return contact

    }
    
    // Удаляет ячейку с выбранным IndexPath и контакт из базы данных
    
    func deleteContact(indexPath:IndexPath) {
        
        // Удаление и присвоение удаленного объекта в константу deletedContact
                // Как это работает?
                //   1. Извлекается ContactGroup с указанной секцией из массива arrayOfContactGroup
                //   2. Идет обращение к атрибуту contacts у извлеченного ContactGroup
                //   3. Вызывается метод remove(at: indexPath.row) у массива из Contact, где передается индекс. Таким образом удаляется выбранный контакт и присаевается к константе deletedContact
        
        let deletedContact = allContactsArrayOfDictionaries[indexPath.section].contacts.remove(at: indexPath.row)
        
        if allContactsArrayOfDictionaries[indexPath.section].contacts.count < 1 {
            allContactsArrayOfDictionaries.remove(at: indexPath.section)
        }
        
        // Здесь уже идет удаление контакта из базы данных
        contactManager.delete(contactToDelete: deletedContact)
    }
    
    
    @IBAction func addUserAction(_ sender: Any) {
        addContactAlert()
    }
    
//    func getSingleContactUser(index: Int) -> String? {
//        let userContact:Contact = allContactsArrayOfDictionaries[index]
//
//
//
//        let text = "\(userContact.firstName) \(userContact.lastName)"
//        return text
//    }
//
//    func getSingleContactUserLastName(index: Int) -> String? {
//        let userContact : Contact = allContactsArrayOfDictionaries[index]
//        let text = "\(userContact.lastName) \(userContact.firstName)"
//        return text
//    }
    
}


// MARK: UITableViewDataSourse & UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allContactsArrayOfDictionaries.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allContactsArrayOfDictionaries[section].contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath) as! ContactTableViewCell
        let contact = getContact(indexPath: indexPath)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            cell.contactTextLabel.text = "\(contact.firstName) \(contact.lastName)"
        }else if segmentedControl.selectedSegmentIndex == 1 {
            cell.contactTextLabel.text = "\(contact.lastName) \(contact.firstName)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return allContactsArrayOfDictionaries[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        let viewController = ContactViewController()
        let contact = getContact(indexPath: indexPath)
        viewController.contact = contact
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContact(indexPath: indexPath)
        }
    }
}


struct Contact: Codable {
    let firstName: String
    let lastName: String
    let phone: String
}


struct ContactGroup {
    let title: String
    var contacts: [Contact]
}


struct ContactManager {
    
    let contactKey: String = "userContacts"
    let userDefaults: UserDefaults = UserDefaults.standard
    
    // Возвращает все данные из базы данных UserDefaults.standard
    func getAllContactsStruct() -> [Contact] {
        var result: [Contact] = []
        
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.object(forKey: contactKey) as? Data {
            do {
                
                let decoder = JSONDecoder()
                result = try decoder.decode([Contact].self, from: data)
                
            }catch {
                print("couldn't decode given data to [Contact] with error: \(error.localizedDescription)")
            }
        }
        
        return result
    }
    
    func add(contact:Contact) {
        var allContacts = getAllContactsStruct()
        allContacts.append(contact)
        
        saveContactAsStruct(allContacts: allContacts)
    }
    
    
    // Записывает массив из Contact в UserDefaults
    
    func saveContactAsStruct(allContacts: [Contact]) {
        
        do{
            
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(allContacts)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey:contactKey)
            
        }catch{
            print("Couldn't encode given [Contact] into data with error \(error.localizedDescription)")
        }
    }
    
    func edit(contactToEdit: Contact, editedContact: Contact) {
        var allContacts = getAllContactsStruct()
        
        for index in 0..<allContacts.count {
            let contact = allContacts[index]
            
            if contact.firstName == contactToEdit.firstName && contact.lastName == contactToEdit.lastName && contact.phone == contactToEdit.phone {
                allContacts.remove(at: index)
                allContacts.insert(editedContact, at: index)
                break
            }
        }
        
        saveContactAsStruct(allContacts: allContacts)
    }
    
    func delete(contactToDelete:Contact) {
        var allContacts = getAllContactsStruct()
        
        for index in 0..<allContacts.count {
            let contact = allContacts[index]
            
            if contact.firstName == contactToDelete.firstName && contact.lastName == contactToDelete.lastName && contact.phone == contactToDelete.phone {
                
                allContacts.remove(at: index)
                break
            }
        }
        saveContactAsStruct(allContacts: allContacts)
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
