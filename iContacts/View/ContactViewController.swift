//
//  ContactViewController.swift
//  iContacts
//
//  Created by Alibek Allamzharov on 07.07.2023.
//

import UIKit

class ContactViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var initialsContainerView: UIView!
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var callStackView: UIStackView!
    @IBOutlet weak var videoStackView: UIStackView!
    @IBOutlet weak var mailStackView: UIStackView!
    @IBOutlet weak var phoneStackView: UIStackView!
    @IBOutlet weak var undoDeleteButton: UIButton!
    @IBOutlet weak var deleteContactButton: UIButton!
    @IBOutlet weak var numberText: UIButton!
    
    var contact: Contact!
    let contactManager = ContactManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContact()
        
        messageStackView.layer.cornerRadius = 5
        callStackView.layer.cornerRadius = 5
        videoStackView.layer.cornerRadius = 5
        mailStackView.layer.cornerRadius = 5
        phoneStackView.layer.cornerRadius = 5
        undoDeleteButton.layer.cornerRadius = 5
        deleteContactButton.layer.cornerRadius = 5

        // Do any additional setup after loading the view.
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContact))
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialsContainerView.layer.cornerRadius = initialsContainerView.frame.height / 2
    }
    
    
    func setupContact() {
        fullNameLabel.text = "\(contact.firstName) \(contact.lastName)"
        initialsLabel.text = "\(contact.firstName.first!) \(contact.lastName.first!)"
        numberText.setTitle(contact.phone, for: .normal)
    }
    
    
    @objc
    func editContact() {
        let alertController = UIAlertController(title: "Edit Contact", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = self.contact.firstName
        }
        alertController .addTextField { textField in
            textField.text = self.contact.lastName
        }
        alertController .addTextField { textField in
            textField.text = self.contact.phone
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let firstName: String = alertController.textFields![0].text!
            let lastName: String = alertController.textFields![1].text!
            let phone: String = alertController.textFields![2].text!
            
            let editedContact = Contact(firstName: firstName, lastName: lastName, phone: phone)
            self.save(editedContact: editedContact)
            
        }
        
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
    func save(editedContact: Contact) {
        contactManager.edit(contactToEdit: contact, editedContact: editedContact)
        contact = editedContact
        setupContact()
    }

}
