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
    
    //MARK:LOCAL PROPERTIES
    var selectedImage: String?
    var userID: String!
    var selectedGroup: String!
    var objectPath: [String]!
    var currentObject: FavObject!
    let db = Firestore.firestore()
    var imgs = [UIImage]()
    let storageRef = Storage.storage().reference()
    var bgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = currentObject.content
        descriptionLabel.sizeToFit()
        bgView = Styling.setUpBg(vc: self, imgName: "bg6")
        titleLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.white
        print("\n\n done")
        titleLabel.text = currentObject.title
        //set up imgs
        scrollView.delegate = self
        
        DispatchQueue.global(qos: .userInteractive).async{
            let downloadGroup = DispatchGroup()
            let imgsRef = self.storageRef.child("/images/\(self.currentObject.title)")
            print("trying to access /images/\(self.currentObject.title)")
            imgsRef.listAll{(result, error) in
                if error != nil{
                    print("Error getting imgs from Firebase: \(error!.localizedDescription)")
                }else{
                    let scrollFrame = self.scrollView.frame
                    print("scroll frame: \(scrollFrame)")
                    print("result count = \(result.items.count)")
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
                                let xPos = CGFloat(i) * self.scrollView.bounds.size.width
                                let frame = CGRect(x: xPos, y: 0, width: scrollFrame.size.width, height: scrollFrame.size.height)
                                print("\n frame: \(frame.origin), \(frame.size.width), \(frame.size.height)\n")
                                let imgView = UIImageView(frame: frame)
                                imgView.contentMode = .scaleAspectFill
                                imgView.image = curImg
                                self.scrollView.contentSize.width = scrollFrame.size.width*(CGFloat(i + 1))
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
        //        group.notify(queue: .main){
        //            //set up scroll
        //            print("imgs.count = \(self.imgs.count)")
        //            let scrollFrame = self.scrollView.frame
        //            print("scroll view: \(self.scrollView.frame.origin), \(self.scrollView.frame.size)")
        //
        //            for index in 0 ..< self.imgs.count {
        //                let xPos = CGFloat(index) * self.scrollView.bounds.size.width
        //                let frame = CGRect(x: xPos, y: 0, width: scrollFrame.size.width, height: scrollFrame.size.height)
        //                print("\n frame: \(frame.origin), \(frame.size.width), \(frame.size.height)\n")
        //                let imgView = UIImageView(frame: frame)
        //                imgView.contentMode = .scaleAspectFill
        //                imgView.image = self.imgs[index]
        //                self.scrollView.contentSize.width = scrollFrame.size.width*(CGFloat(index + 1))
        //                self.scrollView.addSubview(imgView)
        //            }
        //        }
        
        //        loadImgs(after: 2){
        //            //set up scroll
        //            print("imgs.count = \(self.imgs.count)")
        //            let scrollFrame = self.scrollView.frame
        //            print("scroll view: \(self.scrollView.frame.origin), \(self.scrollView.frame.size)")
        //
        //            for index in 0 ..< self.imgs.count {
        //                let xPos = CGFloat(index) * self.scrollView.bounds.size.width
        //                let frame = CGRect(x: xPos, y: 0, width: scrollFrame.size.width, height: scrollFrame.size.height)
        //                print("\n frame: \(frame.origin), \(frame.size.width), \(frame.size.height)\n")
        //                let imgView = UIImageView(frame: frame)
        //                imgView.contentMode = .scaleAspectFill
        //                imgView.image = self.imgs[index]
        //                self.scrollView.contentSize.width = scrollFrame.size.width*(CGFloat(index + 1))
        //                self.scrollView.addSubview(imgView)
        //            }
        //        }
    }
    
    
    func loadImgs(after seconds: Int, completion: @escaping () -> Void){
        let imgsRef = storageRef.child("/images/\(currentObject.title)")
        print("trying to access /images/\(currentObject.title)")
        imgsRef.listAll{(result, error) in
            if error != nil{
                print("Error getting imgs from Firebase: \(error!.localizedDescription)")
            }else{
                print("result count = \(result.items.count)")
                result.items.forEach{(imgRef) in
                    imgRef.getData(maxSize: 1*2000*2000){(data, error) in
                        if error != nil{
                            print("Error getting this img's data:\(error!.localizedDescription)")
                        }else{
                            print("appending img")
                            self.imgs.append(UIImage(data: data!)!)
                        }
                    }
                }
                
            }
        }
        pageCtrl.numberOfPages = imgs.count
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            completion()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageCtrl.currentPage = Int(pageNumber)
    }
    
    func editObject(newCoverImgPath: String, newTitle: String, newContent: String){
        let docRef = self.db.collection("users").document(userID)
        docRef.collection("favGroups").document("\(self.selectedGroup!)").collection("favObjects").document("\(currentObject.title)").delete()
        
        currentObject.title = newTitle
        currentObject.coverImgPath = newCoverImgPath
        currentObject.content = newContent
        
        docRef.collection("favGroups").document("\(self.selectedGroup!)").collection("favObjects").document("\(currentObject.title)").setData(["content": currentObject.content, "coverImgPath": currentObject.coverImgPath, "title": currentObject.title], merge: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditObject",
            let addObjectVC = segue.destination as? AddObjectVC{//as? is casting
            addObjectVC.showVCDelegate = self
            addObjectVC.editingObject = true
            addObjectVC.editingTitle = currentObject.title
            addObjectVC.editingContent = currentObject.content
        }else if segue.identifier == "toContacts"{
            let contactsVC = segue.destination as? ContactsVC
            //email, group name, object name
            contactsVC?.sharingObject = objectPath
        }
    }
}
