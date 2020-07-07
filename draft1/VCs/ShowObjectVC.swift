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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = currentObject.title
        //set up imgs
        scrollView.delegate = self
        pageCtrl.numberOfPages = 1
        loadImgs(after: 1){
            //set up scroll
            print("imgs.count = \(self.imgs.count)")
            let scrollFrame = self.scrollView.frame
            print("scroll view: \(self.scrollView.frame.origin), \(self.scrollView.frame.size)")
            
            for index in 0 ..< self.imgs.count {
                let xPos = CGFloat(index) * self.scrollView.bounds.size.width
                let frame = CGRect(x: xPos, y: 0, width: scrollFrame.size.width, height: scrollFrame.size.height)
                print("\n frame: \(frame.origin), \(frame.size.width), \(frame.size.height)\n")
                let imgView = UIImageView(frame: frame)
                imgView.contentMode = .scaleAspectFill
                imgView.image = self.imgs[index]
                self.scrollView.contentSize.width = scrollFrame.size.width*(CGFloat(index + 1))
                self.scrollView.addSubview(imgView)
            }
        }
        descriptionLabel.text = currentObject.content
        descriptionLabel.sizeToFit()
        Styling.setBg(vc: self, imgName: "bg6")
        titleLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.white
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
            addObjectVC.groupTableDelegate = self
            addObjectVC.editingObject = true
            addObjectVC.editingTitle = currentObject.title
            addObjectVC.editingContent = currentObject.content
            addObjectVC.editingImgPath = currentObject.coverImgPath
        }else if segue.identifier == "toContacts"{
            let contactsVC = segue.destination as? ContactsVC
            //email, group name, object name
            contactsVC?.sharingObject = objectPath
        }
    }

}
