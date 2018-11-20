//
//  PhotoMediaItem.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/20.
//  Copyright © 2018 刘铭. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem {
  override func mediaViewDisplaySize() -> CGSize {
    let defaultSize: CGFloat = 256
    
    var thumbSize: CGSize = CGSize(width: defaultSize, height: defaultSize)
    
    if self.image != nil && image.size.height > 0 && image.size.width > 0 {
      let aspect: CGFloat = self.image.size.width / self.image.size.height
      
      if self.image.size.width > self.image.size.height {
        thumbSize = CGSize(width: defaultSize, height: defaultSize / aspect)
      }else {
        thumbSize = CGSize(width: defaultSize * aspect, height: defaultSize)
      }
    }
    
    return thumbSize
  }
}
