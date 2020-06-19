//
//  ViewController.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DataCollectionProtocol {
    
    //***temp delete group
    func deleteData(index: Int) {
        groups.remove(at: index)
        groupsBook.reloadData()
    }
    
    //***temp delete group
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var groupsBook: UICollectionView!
    
    //MARK:LOCAL PROPERTIES
    var groups = ["Restaurants", "Classes", "Markets"]
    
    override func viewWillAppear(_ animated: Bool) {
        groupsBook.reloadData()
    }
    
    //MARK: SETUP collection view "groupsBook" ------------
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath as IndexPath) as! CollectionViewCell
        cell.groupButton.setTitle(groups[indexPath.row], for: .normal)
        cell.index = indexPath//***temp delete group
        cell.delegate = self//***temp delete group
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func addGroup(newTitle: String){
        groups.append(newTitle)
    }
    
    //MARK: Segues, set delegates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddGroup",
            let addGroupVC = segue.destination as? AddGroupVC{//as? is casting
            addGroupVC.mainVCDelegate = self
        }
    }
}

