//
//  ChatsViewController.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/4.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  var recentChats: [NSDictionary] = []
  var filteredChats: [NSDictionary] = []
  var recentListener: ListenerRegistration!
  
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewWillAppear(_ animated: Bool) {
    loadRecentChats()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    recentListener.remove()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.tableFooterView = UIView()
    
    setTableViewHeader()
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = true
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
  }
  
  @IBAction func createNewChatButtonPressed(_ sender: Any) {
    let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
    
    self.navigationController?.pushViewController(userVC, animated: true)
  }
  
  //MARK: - Load Recent Chats
  func loadRecentChats() {
    recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
      guard let snapshot = snapshot else {return}
      
      self.recentChats = []
      if !snapshot.isEmpty {
        let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
        
        for recent in sorted {
          if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
            self.recentChats.append(recent)
          }
        }
        
        self.tableView.reloadData()
      }
    })
  }
  
  //MARK: - Custom Table View Header
  func setTableViewHeader() {
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
    
    let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
    
    let groupButton = UIButton(frame: CGRect(x: view.frame.width - 110, y: 10, width: 100, height: 20))
    
    groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
    
    groupButton.setTitle("New Group", for: .normal)
    let buttonColor = #colorLiteral(red: 0.01734203286, green: 0.4780371189, blue: 0.9984241128, alpha: 1)
    groupButton.setTitleColor(buttonColor, for: .normal)
    
    let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: view.frame.width, height: 1))
    lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    
    buttonView.addSubview(groupButton)
    headerView.addSubview(buttonView)
    headerView.addSubview(lineView)
    
    tableView.tableHeaderView = headerView
    
    tableView.layoutIfNeeded()
  }
  
  @objc func groupButtonPressed() {
    print("Hello")
  }
  
}

extension ChatsViewController: RecentChatsTableViewCellDelegate {
  func didTapAvatarImage(indexPath: IndexPath) {
    
    var recentChat: NSDictionary!
    
    if searchController.isActive && searchController.searchBar.text != "" {
      recentChat = filteredChats[indexPath.row]
    }else {
      recentChat = recentChats[indexPath.row]
    }
    
    if recentChat[kTYPE] as! String == kPRIVATE {
      reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else { return }
        
        if snapshot.exists {
          let userDictionary = snapshot.data()! as NSDictionary
          let tempUser = FUser(_dictionary: userDictionary)
          self.showUserProfile(user: tempUser)
        }
      }
    }
  }
  
  func showUserProfile(user: FUser) {
    let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileTableViewController
    
    profileVC.user = user
    self.navigationController?.pushViewController(profileVC, animated: true)
  }
  
  
}

extension ChatsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchController.isActive && searchController.searchBar.text != "" {
      return filteredChats.count
    }else {
      return recentChats.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatsTableViewCell
    
    var recentChat: NSDictionary!
    
    if searchController.isActive && searchController.searchBar.text != "" {
      recentChat = filteredChats[indexPath.row]
    }else {
      recentChat = recentChats[indexPath.row]
    }
    
    cell.generateCell(recentChat: recentChat, indexPath: indexPath)
    cell.delegate = self
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    var tempRecent: NSDictionary!
    
    if searchController.isActive && searchController.searchBar.text != "" {
      tempRecent = filteredChats[indexPath.row]
    }else {
      tempRecent = recentChats[indexPath.row]
    }
    
    var muteTitle = "Unmute"
    var mute = false
    
    if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
      muteTitle = "Mute"
      mute = true
    }
    
    let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
      self.deleteRecentChat(recentDictionary: tempRecent)
      self.tableView.reloadData()
    }
    
    let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
      print("Mute \(indexPath)")
    }
    
    muteAction.backgroundColor = #colorLiteral(red: 0.01734203286, green: 0.4780371189, blue: 0.9984241128, alpha: 1)
    
    return [muteAction, deleteAction]
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    var recent: NSDictionary!
    
    if searchController.isActive && searchController.searchBar.text != "" {
      recent = filteredChats[indexPath.row]
    }else {
      recent = recentChats[indexPath.row]
    }
    
    //restart chat
    restartRecentChat(recent: recent)
    
    //show chat view
    
  }
  
  //MARK: - Delete Recent
  func deleteRecentChat(recentDictionary: NSDictionary) {
    if let recentId = recentDictionary[kRECENTID] {
      reference(.Recent).document(recentId as! String).delete()
    }
  }
}


extension ChatsViewController: UISearchResultsUpdating {
  func filterContentForSearchText(searchText: String) {
    filteredChats = recentChats.filter({ (recentChat) -> Bool in
      return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
    })
    
    tableView.reloadData()
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchText: searchController.searchBar.text!)
  }
}
