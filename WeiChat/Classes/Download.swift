//
//  Download.swift
//  WeiChat
//
//  Created by 刘铭 on 2018/11/20.
//  Copyright © 2018 刘铭. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

//image
func uploadImage(image: UIImage, chatRoomId: String, view: UIView, completion: @escaping(_ imageLink: String?)->Void) {
  let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
  progressHUD.mode = .determinateHorizontalBar
  
  let dateString = dateFormatter().string(from: Date())
  let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
  
  let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
  
  let imageData = image.jpegData(compressionQuality: 0.7)
  
  var task: StorageUploadTask!
  task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
    task.removeAllObservers()
    progressHUD.hide(animated: true)
    
    if error != nil {
      print("error uploading image \(error!.localizedDescription)")
      return
    }
    
    storageRef.downloadURL(completion: { (url, error) in
      guard let downloadUrl = url else {
        completion(nil)
        return
      }
      
      completion(downloadUrl.absoluteString)
    })
  })
  
  task.observe(StorageTaskStatus.progress) { (snapshot) in
    progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
  }
}

func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?)->Void) {
  let imageURL = NSURL(string: imageUrl)
  let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first
  
  print(imageFileName!)
  
  if fileExistAtPath(path: imageFileName!) {
    //exist
    if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName!)) {
      completion(contentsOfFile)
    }else {
      print("couldn't generate image")
      completion(nil)
    }
  }else {
    //dosen't exist
    let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
    downloadQueue.async {
      let data = NSData(contentsOf: imageURL! as URL)
      if data != nil {
        var documentURL = getDocumentsURL()
        documentURL = documentURL.appendingPathComponent(imageFileName!, isDirectory: false)
        
        data!.write(to: documentURL, atomically: true)
        let imageToReturn = UIImage(data: data! as Data)
        
        DispatchQueue.main.async {
          completion(imageToReturn)
        }
      }else {
        DispatchQueue.main.async {
          print("no image in database storage")
          completion(nil)
        }
      }
    }
  }
}

// upload video
func uploadVideo(video: NSData, chatRoomId: String, view: UIView, completion: @escaping(_ videoLink: String?)->Void) {
  let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
  progressHUD.mode = .determinateHorizontalBar
  
  let dateString = dateFormatter().string(from: Date())
  let videoFileName = "VideoMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
  
  let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
  
  var task: StorageUploadTask!
  task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
    task.removeAllObservers()
    progressHUD.hide(animated: true)
    
    if error != nil {
      print("error uploading video \(error!.localizedDescription)")
      return
    }
    
    storageRef.downloadURL(completion: { (url, error) in
      guard let downloadUrl = url else {
        completion(nil)
        return
      }
      
      completion(downloadUrl.absoluteString)
    })
  })
  
  task.observe(StorageTaskStatus.progress) { (snapshot) in
    progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
  }
}


func downloadVideo(videoUrl: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String)->Void) {
  let videoURL = NSURL(string: videoUrl)
  let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first
  
  print(videoFileName!)
  
  if fileExistAtPath(path: videoFileName!) {
    //exist
    completion(true, videoFileName!)
  }else {
    //dosen't exist
    let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
    downloadQueue.async {
      let data = NSData(contentsOf: videoURL! as URL)
      if data != nil {
        var documentURL = getDocumentsURL()
        documentURL = documentURL.appendingPathComponent(videoFileName!, isDirectory: false)
        
        data!.write(to: documentURL, atomically: true)
        
        DispatchQueue.main.async {
          completion(true, videoFileName!)
        }
      }else {
        DispatchQueue.main.async {
          print("no video in database storage")
        }
      }
    }
  }
}


func videoThumbnail(video: NSURL) -> UIImage {
  let asset = AVURLAsset(url: video as URL, options: nil)
  let imageGenerator = AVAssetImageGenerator(asset: asset)
  imageGenerator.appliesPreferredTrackTransform = true
  
  let time = CMTime(seconds: 0.5, preferredTimescale: 1000)
  var actualTime = CMTime.zero
  var image: CGImage?
  
  do {
    image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
  }catch let error as NSError {
    print(error.localizedDescription)
  }
  
  let thumbnail = UIImage(cgImage: image!)
  return thumbnail
}


// Helper functions
func getDocumentsURL() -> URL {
  let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
  return documentURL!
}

func fileInDocumentsDirectory(fileName: String) -> String {
  let fileURL = getDocumentsURL().appendingPathComponent(fileName)
  return fileURL.path
}

func fileExistAtPath(path: String) -> Bool {
  var doseExist = false
  let filePath = fileInDocumentsDirectory(fileName: path)
  let fileManager = FileManager.default
  if fileManager.fileExists(atPath: filePath) {
    doseExist = true
  }else {
    doseExist = false
  }
  return doseExist
}


