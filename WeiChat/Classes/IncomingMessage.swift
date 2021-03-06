//
//  IncomingMessage.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/14.
//  Copyright © 2018 刘铭. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
  
  var collectionView: JSQMessagesCollectionView
  
  init(collectionView_: JSQMessagesCollectionView ) {
    collectionView = collectionView_
  }
  
  //MARK: - create Message
  func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
    
    var message: JSQMessage?
    let type = messageDictionary[kTYPE] as! String
    
    switch type {
    case kTEXT:
      print("create text message.")
      message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
    case kPICTURE:
      message = createPictureMessage(messageDictionary: messageDictionary)
    case kVIDEO:
      message = createVideoMessage(messageDictionary: messageDictionary)
    case kAUDIO:
      print("create audio message.")
    case kLOCATION:
      print("create location message.")
    default:
      print("Unknow message type.")
    }
    
    if message != nil {
      return message
    }
    
    return nil 
  }
  
  //MARK: - Create Message type
  func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
    let name = messageDictionary[kSENDERNAME] as! String
    let userId = messageDictionary[kSENDERID] as! String
    
    var date: Date!
    if let create = messageDictionary[kDATE] {
      if (create as! String).count != 14 {
        date = Date()
      }else {
        date = dateFormatter().date(from: create as! String)
      }
    }
    
    let text = messageDictionary[kMESSAGE] as! String
    return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
  }
  
  func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {
    let name = messageDictionary[kSENDERNAME] as! String
    let userId = messageDictionary[kSENDERID] as! String
    
    var date: Date!
    if let create = messageDictionary[kDATE] {
      if (create as! String).count != 14 {
        date = Date()
      }else {
        date = dateFormatter().date(from: create as! String)
      }
    }
    
    let mediaItem = PhotoMediaItem(image:nil)
    
    mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId)
    
    //download image
    downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
      if image != nil {
        mediaItem?.image = image!
        self.collectionView.reloadData()
      }
    }
    
    return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
  }
  
  func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
    let name = messageDictionary[kSENDERNAME] as! String
    let userId = messageDictionary[kSENDERID] as! String
    
    var date: Date!
    if let create = messageDictionary[kDATE] {
      if (create as! String).count != 14 {
        date = Date()
      }else {
        date = dateFormatter().date(from: create as! String)
      }
    }
    
    let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
    
    let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId))
    
    //download video
    downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
      let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
      mediaItem.status = kSUCCESS
      mediaItem.fileURL = url
      imageFromData(pictureData: messageDictionary[kPICTURE] as! String, withBlock: { (image) in
        if image != nil {
          mediaItem.image = image
          self.collectionView.reloadData()
        }
      })
      
      self.collectionView.reloadData()
    }
    
    return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
  }
  
  //MARK: - Helper
  func returnOutgoingStatusForUser(senderId: String) -> Bool {
    if senderId == FUser.currentId() {
      return true
    }else {
      return false
    }
  }
}
