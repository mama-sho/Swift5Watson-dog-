//
//  ShareViewController.swift
//  Swift5Watson
//
//  Created by 上田大樹 on 2020/08/05.
//  Copyright © 2020 ueda.daiki. All rights reserved.
//

import UIKit
import Firebase

//Watsonだよ人工知能
import VisualRecognition
import EMAlertController


class ShareViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    var userName = String()
    var comment = String()
    var imageURLString = String()
    
    //後で確認する
    let visualRecognition = VisualRecognition(version: "2020-08-06", authenticator: WatsonIAMAuthenticator(apiKey: "3HVh91jefoGrxpBCi9V3DAemKqTGOvZ42-jtGCUXdJ0k"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTextView.delegate = self
        
        if UserDefaults.standard.object(forKey: "userName") != nil {
          
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
    }
    
    //他のとこ触ったら
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //TextViewを知じる
        commentTextView.resignFirstResponder()
    }
    
    
    @IBAction func Share(_ sender: Any) {
        
        //watsonに画像のURLを提供
             if contentImageView.image == nil{
                  DispatchQueue.main.async {
                      self.emptyAlert()
                  }
                  return
                }
            
            let timeLineDB = Database.database().reference().child("posts").childByAutoId()
        
            let storage = Storage.storage().reference(forURL: "gs://swift5watson-f626b.appspot.com")
        
            let key = timeLineDB.child("Contents").childByAutoId().key
        
            let imageRef = storage.child("Contents").child("\(String(describing: key!)).jpg")
        
            var contentImageData:Data = Data()
                    
            if contentImageView.image != nil{
                 contentImageData = (contentImageView.image?.jpegData(compressionQuality: 0.01))!
            }
        
            let uploadTask = imageRef.putData(contentImageData, metadata: nil){
                (metaData,error) in
                
                 if error != nil{
                    return
                 }
                
                 imageRef.downloadURL { (url, error) in
                    print(url)
                    
                    if url! != nil {
                        let resultURL = url?.absoluteString
                        print(resultURL!)
                        
                        self.visualRecognition.classify(url:resultURL!) { response,  error in
                            
                            if let error = error {
                                print(error)
                            }

                            let str:String = (response?.result?.images[0].classifiers[0].classes[0].typeHierarchy)!
                            
                            if str.contains("dog") {
                                
                                  DispatchQueue.main.async {
                                     if (self.userName != nil && url?.absoluteString != nil && self.commentTextView.text.isEmpty != true){
                                                      
                                       let timeLineInfo = ["userName":self.userName as Any,"imageURLString":url?.absoluteString as Any,"comment":self.commentTextView.text as Any,"postDate":ServerValue.timestamp()] as [String:Any]
                                    
                                       timeLineDB.updateChildValues(timeLineInfo)
                                    
                                       self.navigationController?.popViewController(animated: true)
                                    
                                     } else {
                                       DispatchQueue.main.async {
                                         self.emptyAlert()
                                
                                       }
                                     }
                                   }
                             } else {
                                DispatchQueue.main.async {
                                    self.checkAlert()
                                    
                                }
                            }
                        }
                    }
                }
        }
        uploadTask.resume()
    }
    
    func checkAlert(){
        
        let alert = EMAlertController(icon: UIImage(named: "dogAlert"), title: "どうやら犬ではないようです！", message: "犬の画像のみ投稿できます！")
        let action1 = EMAlertAction(title: "OK", style: .normal) {
        }
        
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func emptyAlert(){
        
        let alert = EMAlertController(icon: UIImage(named: "dogAlert"), title: "何かが入力されていません！", message: "入力してください。")
        let action1 = EMAlertAction(title: "OK", style: .normal) {
        }
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func openCamera(_ sender: Any) {
        
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            cameraPicker.showsCameraControls = true
            self.present(cameraPicker, animated: true, completion: nil)
            
        }else{
            
            print("エラー")
        }

    }
    
    @IBAction func openAlbum(_ sender: Any) {
        
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
             
             if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                 // インスタンスの作成
                 let cameraPicker = UIImagePickerController()
                 cameraPicker.sourceType = sourceType
                 cameraPicker.delegate = self
                 cameraPicker.allowsEditing = true
                 self.present(cameraPicker, animated: true, completion: nil)
               
             }
             else{
                 print("エラー")
                 
             }
    }
    
    //　撮影が完了時した時に呼ばれる
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           
           
           if let pickedImage = info[.editedImage] as? UIImage
           {
            
            contentImageView.image = pickedImage
               //閉じる処理
               picker.dismiss(animated: true, completion: nil)
               
           }

           
       }
       // 撮影がキャンセルされた時に呼ばれる
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }

}
