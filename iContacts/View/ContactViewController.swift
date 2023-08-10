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
    var text: String?
    
    
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
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        initialsContainerView.layer.cornerRadius = initialsContainerView.frame.height / 2
    }
    
    
    func setupContact() {
        fullNameLabel.text = text
//        initialsLabel.text = "\(contact.firstName.first!) \(contact.lastName.first!)"
//        numberText.setTitle(contact.phone, for: .normal)
    }

}
