//
//  ShowObjectVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift

class ShowObjectVC: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageCtrl: UIPageControl!
    @IBOutlet weak var shareBtn: UIButton!
    
    //MARK:LOCAL PROPERTIES
    var selectedImage: String?
    var userID: String!
    var objectPath: [String]!
    var currentObject: FavObject!
    let db = Firestore.firestore()
    var imgs = [UIImage]()
    let storageRef = Storage.storage().reference()
    var bgView: UIImageView!
    var backFromEdit = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isShared"){
            shareBtn.isHidden = true
        }
        
        scrollView.delegate = self
        let scrollFrame = scrollView.frame
        let widthBound = scrollView.bounds.size.width
        
        
        descriptionLabel.text = currentObject.content
        descriptionLabel.sizeToFit()
        Styling.styleFilledButton(shareBtn, 25)
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            titleLabel.textColor = UIColor.white
            descriptionLabel.textColor = UIColor.white
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            tabBarController?.tabBar.barTintColor = UIColor(red: 0.2353, green: 0.5686, blue: 0.698, alpha: 1.0)
        } else {
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            tabBarController?.tabBar.barTintColor = UIColor.white
        }
        titleLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.white
        print("\n\n done")
        titleLabel.text = currentObject.title
        //set up imgs
        
        DispatchQueue.global(qos: .userInteractive).async{
            let downloadGroup = DispatchGroup()
            let imgsPath = "/images/\(self.objectPath[0])/\(self.objectPath[1])/\(self.objectPath[2])"
            let imgsRef = self.storageRef.child(imgsPath)
            print("trying to access \(imgsPath)")
            imgsRef.listAll{(result, error) in
                if error != nil{
                    print("Error getting imgs from Firebase: \(error!.localizedDescription)")
                }else{
                    print("scroll frame: \(scrollFrame)")
                    print("result count = \(result.items.count)")
                    self.scrollView.contentSize.width = scrollFrame.size.width*(CGFloat(result.items.count))
                    for i in 0 ..< result.items.count{
                        downloadGroup.enter()
                        let imgRef = result.items[i]
                        imgRef.getData(maxSize: 1*2000*2000){(data, error) in
                            if error != nil{
                                print("Error getting this img's data:\(error!.localizedDescription)")
                            }else{
                                //                                print("appending img")
                                //adding to scroll view
                                let curImg = UIImage(data: data!)
                                let xPos = CGFloat(i) * widthBound
                                let frame = CGRect(x: xPos, y: 0, width: scrollFrame.size.width, height: scrollFrame.size.height)
                                print("\n frame: \(frame.origin), \(frame.size.width), \(frame.size.height)\n")
                                let imgView = UIImageView(frame: frame)
                                imgView.contentMode = .scaleAspectFill
                                imgView.image = curImg
                                
                                self.scrollView.addSubview(imgView)
                                self.imgs.append(curImg!)
                                downloadGroup.leave()
                            }
                        }
                    }
                }
            }
            downloadGroup.wait()
        }
        self.pageCtrl.numberOfPages = self.imgs.count
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("isShared: \(UserDefaults.standard.bool(forKey: "isShared"))")
        setupView()
        descriptionLabel.text = currentObject.content
        descriptionLabel.sizeToFit()
        titleLabel.text = currentObject.title
        scrollView.delegate = self
    }
    
    func setupView() {
        let name = Notification.Name("darkModeChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(enableDarkMode), name: name, object: nil)
    }
    
    @objc func enableDarkMode() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if (isDarkMode) {
            bgView.image = UIImage(named: "bg6")
        } else  {
            bgView.image = UIImage(named: "bg5")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageCtrl.currentPage = Int(pageNumber)
    }
    
    func editObject(newCoverImgPath: String, newTitle: String, newContent: String){
        let docRef = self.db.collection("users").document(userID)
        //objectPath[1] is selectedGroup
        docRef.collection("favGroups").document(objectPath[1]).collection("favObjects").document("\(currentObject.title)").delete()
        
        currentObject.title = newTitle
        currentObject.coverImgPath = newCoverImgPath
        currentObject.content = newContent
        
        docRef.collection("favGroups").document(objectPath[1]).collection("favObjects").document(newTitle).setData(["content": currentObject.content, "coverImgPath": currentObject.coverImgPath, "title": newTitle], merge: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditObject",
            let addObjectVC = segue.destination as? AddObjectVC{//as? is casting
            addObjectVC.showVCDelegate = self
            addObjectVC.editingObject = true
            addObjectVC.editingContent = currentObject.content
            addObjectVC.objectPath = objectPath
        }else if segue.identifier == "toContacts"{
            let contactsVC = segue.destination as? ContactsVC
            //email, group name, object name
            contactsVC?.sharingObject = objectPath
        }
    }
}
