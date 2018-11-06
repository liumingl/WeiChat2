//
//  ChatsViewController.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/4.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  @IBAction func createNewChatButtonPressed(_ sender: Any) {
    let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
    
    self.navigationController?.pushViewController(userVC, animated: true)
  }
  
  
  
}
