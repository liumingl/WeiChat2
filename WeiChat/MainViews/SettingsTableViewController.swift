//
//  SettingsTableViewController.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/1.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

  @IBAction func logOutButtonPressed(_ sender: Any) {
    FUser.logOutCurrentUser { (success) in
      if success {
        self.showLoginView()
      }
    }
  }
  
  func showLoginView() {
    let welcomeView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcomeView")
    
    self.present(welcomeView, animated: true, completion: nil)
  }
  

}
