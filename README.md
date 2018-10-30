# WeiChat
视频教程《使用Swift &amp; Firebase开发iOS 12聊天App》的项目源码

Podfile
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'WeiChat' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Firebase/Database'
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'

  pod 'ProgressHUD'
  pod 'MBProgressHUD'
  pod 'IQAudioRecorderController'

  pod 'JSQMessagesViewController', '7.3.3'
  pod 'IDMPhotoBrowser'
  #pod 'ImagePicker'

end
