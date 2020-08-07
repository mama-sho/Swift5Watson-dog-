//
//  TimeLineViewController.swift
//  Swift5Watson
//
//  Created by 上田大樹 on 2020/08/05.
//  Copyright © 2020 ueda.daiki. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class TimeLineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let refresh = UIRefreshControl()
    
    var postArray = [PostData]()
    
    var postImageView = UIImageView()
    
    var userNameLabel = UILabel()
    var commentLabel = UILabel()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresh
        
        //リフレッシュされ、Valueが変わった時に
        refresh.addTarget(self, action: #selector(update), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        //ナビゲーションを消す
        self.navigationController?.isNavigationBarHidden = true
        //データを引っ張ってくる
        fetchData()
        tableView.reloadData()
        
    }
    
    @objc func update() {
        
        fetchData()
        
        tableView.reloadData()
        //リフレッシュをやめる
        refresh.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let contentImageURL = URL(string: self.postArray[indexPath.row].imageURLString)!
        
        let postImageView = cell.contentView.viewWithTag(1) as! UIImageView

        postImageView.sd_setImage(with: URL(string: self.postArray[indexPath.row].imageURLString)) { (image, error, _, _) in
            
            if error == nil {
                
                cell.setNeedsLayout()
            }
        }
        userNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        userNameLabel.text = postArray[indexPath.row].userName
        
        commentLabel = cell.contentView.viewWithTag(3) as! UILabel
        commentLabel.text = postArray[indexPath.row].comment
        
        return cell
            
    }
    
    func fetchData() {
        
        //どこから引っ張ってくるのか
        let fetchDataRef = Database.database().reference().child("posts").queryLimited(toLast: 100).queryOrdered(byChild: "postDate").observe(.value) {
            (snapshot) in
            
            self.postArray.removeAll()
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshot {
                    
                    if let postContents = snap.value as? [String:Any] {
                        
                        let postData = PostData()
                        
                        let userName = postContents["userName"] as? String
                        let imageURLString = postContents["imageURLString"] as? String
                        let comment = postContents["comment"] as? String
                        var postDate:CLong?
                        if let postedDate = postContents["postDate"] as? CLong{
                            postDate = postedDate
                        }
                        postData.userName = userName!
                        postData.imageURLString = imageURLString!
                        postData.comment = comment!
                        self.postArray.append(postData)
                        
                    }
                }
                self.tableView.reloadData()
            }
        }
        
    }
    
    //セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //セルの高さ
        return 534
    }
    

    @IBAction func share(_ sender: Any) {
        
        let shareVC = self.storyboard?.instantiateViewController(identifier: "share") as! ShareViewController
        self.navigationController?.pushViewController(shareVC, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
