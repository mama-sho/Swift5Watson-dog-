//
//  ViewController.swift
//  Swift5Watson
//
//  Created by 上田大樹 on 2020/08/05.
//  Copyright © 2020 ueda.daiki. All rights reserved.
//

import UIKit
import Photos


class ViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        
        //カメラの使用許可を促す処理
        //info.plitで　+ privacy - Camera Usageを追加
        //info.plist　+  privacy - Photo Library usageを追加
        PHPhotoLibrary.requestAuthorization {
            (status) in
            switch status {
            case .authorized: break
            case .denied: break
            case .notDetermined: break
            case .restricted: break
            }
        }
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            
            userNameTextField.text = (UserDefaults.standard.object(forKey: "userName") as! String)
        }
    }
    
    //viewdiloadの次に呼ばれ、画面が表示されるたびに、呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
              
            performSegue(withIdentifier: "next", sender: nil)
          }
        
    }
    
    @IBAction func login(_ sender: Any) {
        //保存
        UserDefaults.standard.set(userNameTextField.text, forKey: "userName")
        //画面遷移　segueID
        performSegue(withIdentifier: "next", sender: nil)
    }
    
    //別のところタップで閉じるよ！
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userNameTextField.resignFirstResponder()
    }

}

