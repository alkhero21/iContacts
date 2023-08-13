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
    var timer: Timer?
    var countDown: Int = 0
    var countDownTotal: Int = 5
    
    
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
    
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this contact?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteContact()
        }
        alertController.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
    @IBAction func undoDeleteButtonTapped(_ sender: Any) {
        timer?.invalidate()
        
        progressView.progress = 1
        progressView.isHidden = true
        undoDeleteButton.isHidden = true
        deleteContactButton.isHidden = false
        
        contactManager.add(contact: contact)
    }
    
    
    @IBAction func callButtonTapped(_ sender: Any) {
        
        open(contactType: .call)
    }
    
    
    @IBAction func faceTimeButtonTapped(_ sender: Any) {
        open(contactType: .faceTime)
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        open(contactType: .message)
    }
    
    
    @IBAction func phoneNumberTapped(_ sender: Any) {
        open(contactType: .call)
    }
    
    func deleteContact() {
        contactManager.delete(contactToDelete: self.contact)
        deleteContactButton.isHidden = true
        undoDeleteButton.isHidden = false
        progressView.progress = 1
        progressView.isHidden = false
        
        sheduleTimer()
    }
    
    func sheduleTimer() {
        countDown = countDownTotal
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
    }
    
    @objc
    func updateProgressView() {
        countDown -= 1
        progressView.progress = Float(countDown) / Float(countDownTotal)
        
        if countDown == 0 {
            timer?.invalidate()
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    func open(contactType: ContactType) {
            
        // Извлекается номер телефона
        let phone = contact.phone
        // Удаляются все символы '+' из сторки phone
        let phoneWithoutPlus = phone.replacingOccurrences(of: "+", with: "")
        // Удаляются все символы ' ' (пробелы) из сторки phoneWithoutPlus
        let phoneWithoutSpacing = phoneWithoutPlus.replacingOccurrences(of: " ", with: "")
        // Создается сторка которая указывает путь к приложению
        let urlString: String = "\(contactType.urlScheme)" + phoneWithoutSpacing
        
        // Проверяется на преображение сторки urlString в URL
        guard let url = URL(string: urlString) else {
            return
        }
        // Открывает приложение на iPhone/iPad с указанным путем. Например: "tel://77082968612" приложение контакты и позвонит на указанный номер
        UIApplication.shared.open(url)
    }
}


enum ContactType {
    case message
    case call
    case faceTime
    
    var urlScheme: String {
        switch self {
        case .message:
            return "sms://"
        case .call:
            return "tel://"
        case .faceTime:
            return "facetime://"
        }
    }
}
