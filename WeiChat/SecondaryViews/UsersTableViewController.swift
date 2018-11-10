//
//  UsersTableViewController.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/4.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseFirestore

class UsersTableViewController: UITableViewController {
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var filterSegmentedController: UISegmentedControl!
  
  var allUsers: [FUser] = []
  var filteredUsers: [FUser] = []
  var allUsersGroupped = NSDictionary() as! [String: [FUser]]
  var sectionTitleList: [String] = []
  
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Users"
    navigationItem.largeTitleDisplayMode = .never
    
    tableView.tableFooterView = UIView()
    
    navigationItem.searchController = searchController
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    
    loadUsers(filter: kCITY)
  }
  
  //MARK: - Load Users Functions
  func loadUsers(filter: String) {
    ProgressHUD.show()
    
    var query: Query!
    
    switch filter {
    case kCITY:
      query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kLASTNAME, descending: false)
    case kCOUNTRY:
      query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kLASTNAME, descending: false)
    default:
      query = reference(.User).order(by: kLASTNAME, descending: false)
    }
    
    query.getDocuments { (snapshot, error) in
      self.allUsers = []
      self.sectionTitleList = []
      self.allUsersGroupped = [:]
      
      if error != nil {
        print(error!.localizedDescription)
        ProgressHUD.dismiss()
        return
      }
      
      guard let snapshot = snapshot else { ProgressHUD.dismiss(); return }
      
      if !snapshot.isEmpty {
        for userDictionary in snapshot.documents {
          let userDictionary = userDictionary.data() as NSDictionary
          let fUser = FUser(_dictionary: userDictionary)
          
          if fUser.objectId != FUser.currentId() {
            self.allUsers.append(fUser)
          }
        }
        
        //split to groups
        self.splitDataIntoSection()
      }
      
      self.tableView.reloadData()
      ProgressHUD.dismiss()
    }
  }
  
  //MARK: - IBActions
  
  @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      loadUsers(filter: kCITY)
    case 1:
      loadUsers(filter: kCOUNTRY)
    default:
      loadUsers(filter: "")
    }
  }
  
  //MARK: - split Data into section
  
  fileprivate func splitDataIntoSection() {
    var sectionTitle = ""
    
    for i in 0 ..< self.allUsers.count {
      let currentUser = self.allUsers[i]
      let firstChar = currentUser.lastname.first
      let firstCharString = "\(firstChar!)"
      
      if firstCharString != sectionTitle {
        sectionTitle = firstCharString
        self.allUsersGroupped[sectionTitle] = []
        self.sectionTitleList.append(sectionTitle)
      }
      self.allUsersGroupped[sectionTitle]?.append(currentUser)
    }
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    
    if searchController.isActive && searchController.searchBar.text != "" {
      return 1
    }else {
      return allUsersGroupped.count
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive && searchController.searchBar.text != "" {
      return filteredUsers.count
    }else {
      
      //find section Title
      let sectionTitle = self.sectionTitleList[section]
      
      let users = self.allUsersGroupped[sectionTitle]
      return users!.count
    }
    
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
    
    var user: FUser
    
    if searchController.isActive && searchController.searchBar.text != "" {
      user = filteredUsers[indexPath.row]
    }else {
      let sectionTitle = self.sectionTitleList[indexPath.section]
      let users = self.allUsersGroupped[sectionTitle]
      user = users![indexPath.row]
    }
    
    cell.delegate = self
    cell.generateCellWith(fUser: user, indexPath: indexPath)
    
    return cell
  }
  
  //MARK: - table view delegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    var user: FUser
    
    if searchController.isActive && searchController.searchBar.text != "" {
      user = filteredUsers[indexPath.row]
    }else {
      let sectionTitle = self.sectionTitleList[indexPath.section]
      let users = self.allUsersGroupped[sectionTitle]
      user = users![indexPath.row]
    }
    
    startPrivateChat(user1: FUser.currentUser()!, user2: user)
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if searchController.isActive && searchController.searchBar.text != "" {
      return ""
    }else {
      return sectionTitleList[section]
    }
  }
  
  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    if searchController.isActive && searchController.searchBar.text != "" {
      return nil
    }else {
      return sectionTitleList
    }
  }
  
  override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return index
  }
}


//MARK: - Search Results Updating

extension UsersTableViewController: UISearchResultsUpdating {
  
  //MARK: - Search controller functions
  func filterContentForSearchText(searchText: String, scope: String = "All") {
    filteredUsers = allUsers.filter({ (user) -> Bool in
      return user.fullname.lowercased().contains(searchText.lowercased())
    })
    
    tableView.reloadData()
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchText: searchController.searchBar.text!)
  }
}

extension UsersTableViewController: UserTableViewCellDelegate {
  func didTapAvatarImage(indexPath: IndexPath) {
    let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileTableViewController
    
    var user:FUser
    if searchController.isActive && searchController.searchBar.text != "" {
      user = filteredUsers[indexPath.row]
    }else {
      let sectionTitle = self.sectionTitleList[indexPath.section]
      let users = self.allUsersGroupped[sectionTitle]
      user = users![indexPath.row]
    }
    profileVC.user = user
    self.navigationController?.pushViewController(profileVC, animated: true)
  }
  
  
}
