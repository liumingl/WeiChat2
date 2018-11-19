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
      print("create picture message.")
    case kVIDEO:
      print("create video message.")
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
}
