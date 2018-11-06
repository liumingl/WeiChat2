//
//  WelcomeViewController.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/10/28.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {
  
  @IBOutlet weak var emailTextField: UITextField!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  @IBOutlet weak var repeatPasswordTextField: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  @IBAction func loginButtonPressed(_ sender: Any) {
    dismissKeyboard()
    
    if emailTextField.text != "" && passwordTextField.text != "" {
      loginUser()
    }else {
      ProgressHUD.showError("email & password is missing!")
    }
  }
  
  @IBAction func registerButtonPressed(_ sender: Any) {
    dismissKeyboard()
    
    if emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != "" {
      if passwordTextField.text == repeatPasswordTextField.text {
          registerUser()
      }
    }else {
      ProgressHUD.showError("All fields are required!")
    }
  }
  
  @IBAction func backgroundTap(_ sender: Any) {
    dismissKeyboard()
  }
  
  //MARK: - Helper functions
  
  func loginUser() {
    ProgressHUD.show("Login...")
    
    FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
      if error != nil {
        ProgressHUD.showError(error!.localizedDescription)
        return
      }
      
      self.goToApp()
    }
    
  }
  
  func registerUser() {
    
    performSegue(withIdentifier: "welcomeToFinishReg", sender: nil)
    
    cleanTextFields()
    dismissKeyboard()
  }
  
  func goToApp() {
    ProgressHUD.dismiss()
    cleanTextFields()
    dismissKeyboard()
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID: FUser.currentId()])
    
    let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
    
    present(mainView, animated: true, completion: nil)
  }
  
  
  func dismissKeyboard() {
    self.view.endEditing(false)
  }
  
  func cleanTextFields() {
    emailTextField.text = ""
    passwordTextField.text = ""
    repeatPasswordTextField.text = ""
  }
  
  //MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "welcomeToFinishReg" {
      let vc = segue.destination as! FinishRegistrationViewController
      
      vc.email = emailTextField.text
      vc.password = passwordTextField.text
      
    }
  }
}
