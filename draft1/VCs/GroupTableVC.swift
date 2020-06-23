//
//  GroupTableVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class GroupTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var groupTable: UITableView!
    
    //MARK:LOCAL PROPERTIES
    var favObjects: Array<FavObject> = []
    
    let showObjectSegueIdentifier = "toShowObject"
       
    override func viewDidLoad() {
        super.viewDidLoad()
         sampleObjects()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        groupTable.reloadData()
    }
    
   func addObject(newCoverImg: UIImage, newTitle: String, newContent: String){
        //create new object
        let newObject = FavObject(coverImage: newCoverImg, title: newTitle, content: newContent)
        //add it to objects
        favObjects.append(newObject)
        //create new ObjectCell
        print("add object, size = \(favObjects.count)")
    }
    
    //before implementing getImage from phone, just for table view testing
    func sampleObjects(){
        //var tempFavObjects: [FavObject] = []

        let object1 = FavObject(coverImage: UIImage(named: "Torchy's")!, title: "Torchy's tacos", content: "have tacos")
        let object2 = FavObject(coverImage: UIImage(named:"RaisingCanes")!, title: "Raising Cane's", content: "Chicken strips")

        favObjects.append(object1)
        favObjects.append(object2)

    }

    //MARK: SETUP tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("size = \(favObjects.count)")
        return favObjects.count
    }
    
    //indexPath: row index of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "objectCell", for: indexPath as IndexPath) as! ObjectCell
        let curFavObject = favObjects[indexPath.item]
        //print("curFavObject name: \(curFavObject.title)")
        cell.setObjectCell(sourceObj: curFavObject)
        return cell
    }
    
    //swipe to delete object
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            favObjects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
    
    //MARK: Segues, set delegates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddObject",
            let addObjectVC = segue.destination as? AddObjectVC{//as? is casting
            addObjectVC.groupTableDelegate = self
        } else if segue.identifier == showObjectSegueIdentifier,
            let showObjectVC = segue.destination as? ShowObjectVC,
            let objectIndex = groupTable.indexPathForSelectedRow?.row {
            showObjectVC.currentObject = favObjects[objectIndex]
            
        }
    }
    
    
}
