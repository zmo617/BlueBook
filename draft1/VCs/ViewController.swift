//
//  ViewController.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DataCollectionProtocol {
//    func passData(index: Int) {
//        <#code#>
//    }
    
    func deleteData(index: Int) {
        groups.remove(at: index)
        groupsBook.reloadData()
    }
    
    
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var groupsBook: UICollectionView!
    
    
    //var longPressRecognizer: UILongPressGestureRecognizer!
    
    var groups = ["Restaurants", "Classes", "Markets"]
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //        // Do any additional setup after loading the view.
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        groupsBook.reloadData()
        
    }
    
    var mMode: Mode = .view{
      didSet {
        switch mMode {
        case .view:
          for (key, value) in dictionarySelectedIndecPath {
            if value {
              groupsBook.deselectItem(at: key, animated: true)
            }
          }
          
          dictionarySelectedIndecPath.removeAll()
          
          selectBarButton.title = "Select"
          navigationItem.leftBarButtonItem = nil
          groupsBook.allowsMultipleSelection = false
        case .select:
          selectBarButton.title = "Cancel"
          navigationItem.leftBarButtonItem = deleteBarButton
          groupsBook.allowsMultipleSelection = true
        }
      }
    }
    
    lazy var selectBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(didSelectButtonClicked(_:)))
        return barButtonItem
    }()
    
    lazy var deleteBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didDeleteButtonClicked(_:)))
        return barButtonItem
    }()
    
    var dictionarySelectedIndecPath: [IndexPath: Bool] = [:]
    
    @objc func didSelectButtonClicked(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
    }
    
    @objc func didDeleteButtonClicked(_ sender: UIBarButtonItem) {
        var deleteNeededIndexPaths: [IndexPath] = []
        for (key, value) in dictionarySelectedIndecPath {
            if value {
                deleteNeededIndexPaths.append(key)
            }
        }
        for i in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item }) {
            groups.remove(at: i.item)
        }
        
        groupsBook.deleteItems(at: deleteNeededIndexPaths)
        dictionarySelectedIndecPath.removeAll()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCell", for: indexPath as IndexPath) as! CollectionViewCell
        cell.groupButton.setTitle(groups[indexPath.row], for: .normal)
        cell.index = indexPath
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func addGroup(newTitle: String){
        groups.append(newTitle)
    }
    
    //prepare for segue, set delegates
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddGroup",
            let addGroupVC = segue.destination as? AddGroupVC{//as? is casting
            addGroupVC.mainVCDelegate = self
        }
    }
    
    
}

