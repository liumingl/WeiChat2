//
//  FinishRegistrationViewController.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/10/30.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController {
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var surnameTextField: UITextField!
  @IBOutlet weak var countryTextField: UITextField!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var phoneTextField: UITextField!
  
  @IBOutlet weak var avatarImageView: UIImageView!
  
  var email: String!
  var password: String!
  
  var avatarImage: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print(email, password)
  }
  
  @IBAction func doneButtonPressed(_ sender: UIButton) {
    dismissKeyboard()
    ProgressHUD.show("Register...")
    
    if nameTextField.text != "" && surnameTextField.text != "" && countryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" {
     
      FUser.registerUserWith(email: email, password: password, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
        if error != nil {
          ProgressHUD.dismiss()
          ProgressHUD.showError(error!.localizedDescription)
          return
        }
        
        registerUser()
      }
    }else {
      ProgressHUD.showError("All fields are required!.")
    }
  }
  
  @IBAction func cancelButtonPressed(_ sender: UIButton) {
    cleanTextFields()
    dismissKeyboard()
    
    self.dismiss(animated: true, completion: nil)
  }
  
  //MARK: - Helpers
  
  func dismissKeyboard() {
    self.view.endEditing(false)
  }
  
  func cleanTextFields() {
    nameTextField.text = ""
    surnameTextField.text = ""
    countryTextField.text = ""
    cityTextField.text = ""
    phoneTextField.text = ""
  }
  
  func registerUser() {
    
  }
}
