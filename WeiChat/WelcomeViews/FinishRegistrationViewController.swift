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
        
        self.registerUser()
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
    let fullName = surnameTextField.text! + " " + nameTextField.text!
    var tempDictionary: Dictionary = [kFIRSTNAME: nameTextField.text!, kLASTNAME: surnameTextField.text!, kFULLNAME: fullName, kCOUNTRY: countryTextField.text!, kCITY: cityTextField.text!, kPHONE: phoneTextField.text!] as [String: Any]
    
    if avatarImage == nil {
      imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
        let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
        let avatar = avatarIMG?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: Data.Base64EncodingOptions.RawValue(0)))
        
        tempDictionary[kAVATAR] = avatar
        
        // finishRegistration
        self.finishRegistration(withValues: tempDictionary)
      }
    }else {
      let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
      let avatar = avatarData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: Data.Base64EncodingOptions.RawValue(0)))
      tempDictionary[kAVATAR] = avatar
      
      // finishRegistration
      self.finishRegistration(withValues: tempDictionary)
    }
  }
  
  func finishRegistration(withValues: [String: Any]) {
    updateCurrentUserInFirestore(withValues: withValues) { (error) in
      if error != nil {
        DispatchQueue.main.async {
          ProgressHUD.showError(error!.localizedDescription)
        }
        
        return
      }
      
      ProgressHUD.dismiss()
      // Go To App
      self.goToApp()
    }
  }
  
  func goToApp() {
    cleanTextFields()
    dismissKeyboard()
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
    
    let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
    
    present(mainView, animated: true, completion: nil)
  }
}
