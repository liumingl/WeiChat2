//
//  ChatViewController.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/13.
//  Copyright © 2018 刘铭. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
  
  var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
  var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
  
  var chatRoomId: String!
  var memberIds: [String]!
  var membersToPush: [String]!
  var titleName: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.senderId = FUser.currentId()
    self.senderDisplayName = FUser.currentUser()?.fullname
    
    //custom send button
    self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
    self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    
    navigationItem.largeTitleDisplayMode = .never
    self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
    
    collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
    collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
}

extension ChatViewController {
  override func didPressAccessoryButton(_ sender: UIButton!) {
    let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
      print("Camera")
    }
    
    let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
      print("Photo Library")
    }
    
    let shareVideo = UIAlertAction(title: "Share Video", style: .default) { (action) in
      print("Video Library")
    }
    
    let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
      print("Share Location")
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    
    takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
    sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
    shareVideo.setValue(UIImage(named: "video"), forKey: "image")
    shareLocation.setValue(UIImage(named: "location"), forKey: "image")
    
    optionMenu.addAction(takePhotoOrVideo)
    optionMenu.addAction(sharePhoto)
    optionMenu.addAction(shareVideo)
    optionMenu.addAction(shareLocation)
    optionMenu.addAction(cancel)
    
    self.present(optionMenu, animated: true, completion: nil)
  }
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
    if text != "" {
      sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
      updateSendButton(isSend: false)
      
    }else {
      // Audio message
    }
  }
  
  override func textViewDidChange(_ textView: UITextView) {
    if textView.text != "" {
      updateSendButton(isSend: true)
    }else {
      updateSendButton(isSend: false)
    }
  }
  
  //MARK: - Send Message function
  func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
    
    var outgoingMessage: OutgoingMessages?
    let currentUser = FUser.currentUser()!
    
    // text message
    if let text = text {
      outgoingMessage = OutgoingMessages(message: text, senderId: currentUser.objectId, senderName: currentUser.fullname, date: date, status: kDELIVERED, type: kTEXT)
    }
    
    outgoingMessage!.sendMessage(chatRoomId: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, memberToPush: membersToPush)
    
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    self.finishSendingMessage()
  }
  
  
  //MARK: - Custom Send Button
  func updateSendButton(isSend: Bool) {
    if isSend {
      self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
    }else {
      self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
    }
  }
}

extension JSQMessagesInputToolbar {
  override open func didMoveToWindow() {
    super.didMoveToWindow()
    guard let window = window else { return }
    if #available(iOS 11.0, *) {
      let anchor = window.safeAreaLayoutGuide.bottomAnchor
      bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true
    }
  }
}
