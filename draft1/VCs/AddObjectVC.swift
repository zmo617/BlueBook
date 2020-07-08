//
//  AddObjectVC.swift
//  draft1
//
//  Created by Claire Mo on 6/14/20.
//  Copyright © 2020 Zongying Mo. All rights reserved.
//

import UIKit
import Speech
import Firebase
import FirebaseStorage
import BSImagePicker
import Photos

class AddObjectVC: UIViewController, UINavigationControllerDelegate, SFSpeechRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var titleTxtField: UITextField!
    
    @IBOutlet weak var photoBook: UICollectionView!
    @IBOutlet weak var addPicBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    
    
    //MARK:LOCAL PROPERTIES
    var groupTableDelegate: UIViewController!
    var showVCDelegate: UIViewController!
    var bgView: UIImageView!
    var objectPath: [String]!
    //speech rec
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var speechTask: SFSpeechRecognitionTask!
    var isRecording: Bool = false
    //images
    let storageRef = Storage.storage().reference()
    var imgURLs = [URL]()
    var selectedAssets = [PHAsset]()
    var photos = [UIImage]()
    //for creating new object
    var coverImgPath: String!
    var objTitle: String!
    //editing mode
    var editingObject: Bool!
    var editingContent: String = ""
    var editingImgPressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n\n objectPath: \(objectPath)")
        if (editingObject) {
            titleTxtField.text = objectPath[2]
            contentTxtView.text = editingContent
            
            //            DispatchQueue.global(qos: .userInteractive).async{
            //                let downloadGroup = DispatchGroup()
            let imgsRef = self.storageRef.child("/images/\(self.objectPath[0])/\(self.objectPath[1])/\(self.objectPath[2])")
            print("trying to access /images/\(self.objectPath[0])/\(self.objectPath[1])/\(self.objectPath[2])")
            //downloadGroup.enter()
            imgsRef.listAll{(result, error) in
                if error != nil{
                    print("Error getting imgs from Firebase: \(error!.localizedDescription)")
                }else{
                    
                    print("result count = \(result.items.count)")
                    result.items.forEach{(imgRef) in
                        //downloadGroup.enter()
                        imgRef.getData(maxSize: 1*2000*2000){(data, error) in
                            if error != nil{
                                print("Error getting this img's data:\(error!.localizedDescription)")
                            }else{
                                print("appending img")
                                self.photos.append(UIImage(data: data!)!)
                                self.photoBook.reloadData()
                                //downloadGroup.leave()
                            }
                        }
                    }
                    //downloadGroup.leave()
                }
            }
            //downloadGroup.wait()
            //      }
            print("photos.count: \(self.photos.count)")
        }
        
        createBtn.setTitleColor(UIColor.systemBlue, for: .normal)
        bgView = Styling.setUpBg(vc: self, imgName: "bg6")
        Styling.styleTextField(titleTxtField)
        addPicBtn.setTitleColor(UIColor.systemBlue, for: .normal)
        
        photoBook.delegate = self
        photoBook.dataSource = self
        photoBook.backgroundColor = .clear
        photoBook.backgroundView = nil
        photoBook.layer.borderColor = UIColor.white.cgColor
        photoBook.layer.borderWidth = 1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        photoBook.reloadData()
    }
    //    func loadImgs(after seconds: Int, completion: @escaping () -> Void){
    //        let imgsRef = storageRef.child("/images/\(self.objectPath[0])/\(self.objectPath[1])/\(self.objectPath[2])")
    //        print("trying to access /images/\(self.objectPath[0])/\(self.objectPath[1])/\(self.objectPath[2])")
    //        imgsRef.listAll{(result, error) in
    //            if error != nil{
    //                print("Error getting imgs from Firebase: \(error!.localizedDescription)")
    //            }else{
    //                print("result count = \(result.items.count)")
    //                result.items.forEach{(imgRef) in
    //                    imgRef.getData(maxSize: 1*2000*2000){(data, error) in
    //                        if error != nil{
    //                            print("Error getting this img's data:\(error!.localizedDescription)")
    //                        }else{
    //                            print("appending img")
    //                            self.photos.append(UIImage(data: data!)!)
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        let deadline = DispatchTime.now() + .seconds(seconds)
    //        DispatchQueue.main.asyncAfter(deadline: deadline) {
    //            completion()
    //        }
    //    }
    
    //MARK: SPEECH RECOGNITION ----------------------------
    //request authorization first
    @IBAction func recordPressed(_ sender: Any) {
        isRecording = !isRecording
        if isRecording{
            recordBtn.setTitle("stop", for: .normal)
            requestSpeechRec()
        }else{
            stopRecognition()
            recordBtn.setTitle("record", for: .normal)
        }
        
    }
    
    func requestSpeechRec(){
        //self.recordBtn.isEnabled = false
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized{
                print("~~~Speech rec enabled")
                //self.recordBtn.isEnabled = true
                //call startRecognition
                do {
                    try self.startRecognition()
                } catch let error {
                    print("There was a problem starting recording: \(error.localizedDescription)")
                }
                
            }else{
                
            }
        }
    }
    
    //start speech rec if enabled
    func startRecognition() throws{
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat){(buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        speechTask = speechRecognizer?.recognitionTask(with: request) {
            [unowned self]
            (result, _) in
            if let transcription = result?.bestTranscription {
                self.contentTxtView.text = transcription.formattedString
            }
        }
    }
    
    func stopRecognition(){
        audioEngine.stop()
        request.endAudio()
        speechTask?.cancel()
    }
    
    
    //MARK: ADD PICTURE ----------------------------
    func convertAssetsToImgs(){
        if selectedAssets.count != 0{
            for i in 0 ..< selectedAssets.count{
                let curAsset = selectedAssets[i]
                curAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()){(editingInput, info) in
                    if let input = editingInput, let imgURL = input.fullSizeImageURL{
                        self.imgURLs.append(imgURL)
                    }
                }
                _ = curAsset.image(completionHandler: {(img) in
                    self.photos.append(img)
                    print("img \(i) converted to UIImage")
                })
            }
        }
    }
    
    @IBAction func importImg(_ sender: Any) {
        let vc = BSImagePickerViewController()
        self.bs_presentImagePickerController(vc, animated: true,
                                             select: {(asset: PHAsset) in
        }, deselect: {(asset: PHAsset) in
            
        }, cancel: {(assets: [PHAsset]) in
            
        }, finish: {(assets: [PHAsset]) in
            for i in 0 ..< assets.count{
                self.selectedAssets.append(assets[i])
            }
            self.convertAssetsToImgs()
            self.photoBook.reloadData()
        }, completion: nil)
        
        //*********
        //        let imgPickerController = UIImagePickerController()
        //        imgPickerController.delegate = self
        //
        //        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        //
        //        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
        //            if UIImagePickerController.isSourceTypeAvailable(.camera){
        //                imgPickerController.sourceType = .camera
        //                self.present(imgPickerController, animated: true, completion: nil)
        //            }else{
        //                print("Camera not available")
        //            }
        //
        //        }))
        //
        //        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (action: UIAlertAction) in
        //            imgPickerController.sourceType = .photoLibrary
        //            self.present(imgPickerController, animated: true, completion: nil)
        //        }))
        //
        //        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //
        //        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //upload image from memory. imgRef: path name
    func uploadImgToStorage(imgURL: URL, imgRef: String){
        let ref = storageRef.child(imgRef)
        let uploadTask = ref.putFile(from: imgURL, metadata: nil){(metadata, error) in
            guard metadata != nil else{
                //has an error
                print(error!.localizedDescription)
                return
            }
            print("\n\n Upload \(imgRef) succeeded")
        }
    }
    
    //    //info is a dictionary containing img data.
    //    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    //        //old name: info[UIImagePickerControllerOriginalImage]
    //        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    //
    //        coverImgView.image = img
    //        self.imgURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
    //        editingImgPressed = true
    //        picker.dismiss(animated: true, completion: nil)
    //    }
    //
    //    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //        picker.dismiss(animated: true, completion: nil)
    //    }
    
    func uploadImgs(after seconds: Int, completion: @escaping () -> Void){
        //        let firstAsset = selectedAssets[0]
        //               firstAsset.requestContentEditingInput(with: PHContentEditingInputRequestOptions()){(editingInput, info) in
        //                   if let input = editingInput, let imgURL = input.fullSizeImageURL{
        //                    self.coverImgPath = "/images/\(self.objTitle!)/\(imgURL.path)"
        //
        //                       self.uploadImgToStorage(imgURL: imgURL, imgRef: "/images/\(self.objTitle!)/\(imgURL.path)")
        //                   }
        //               }
        
        
        //        let deadline = DispatchTime.now() + .seconds(seconds)
        //        DispatchQueue.main.asyncAfter(deadline: deadline) {
        //            completion()
        //        }
    }
    
    //create button pressed
    @IBAction func createObject(_ sender: Any) {
        objTitle = titleTxtField.text!
        //upload imgs
        DispatchQueue.global(qos: .userInteractive).async{
            let downloadGroup = DispatchGroup()
            
            for i in 0 ..< self.selectedAssets.count{
                downloadGroup.enter()
                let imgName = "/images/\(self.objectPath[0])/\(self.objectPath[1])/\(self.objTitle!)/\(self.imgURLs[i].hashValue)"
                
                if i == 0{
                    self.coverImgPath = imgName
                }
                self.uploadImgToStorage(imgURL: self.imgURLs[i], imgRef: imgName)
                downloadGroup.leave()
            }
            downloadGroup.wait()
        }
        if self.coverImgPath == nil{
            print("coverImgPath nil \n\n")
        }else{
            print("\n coverImgPath: \(self.coverImgPath!) \n" )
            if self.editingObject{
                let showVC = self.showVCDelegate as! ShowObjectVC
                showVC.editObject(newCoverImgPath: self.coverImgPath, newTitle: self.objTitle, newContent: self.contentTxtView.text)
                showVC.backFromEdit = true
                
            }else{
                let groupVC = self.groupTableDelegate as! GroupTableVC
                groupVC.addObject(newCoverImgPath: self.coverImgPath, newTitle: self.objTitle, newContent: self.contentTxtView.text)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoBook.dequeueReusableCell(withReuseIdentifier: "SelectedImgCell", for: indexPath) as! SelectedImgCell
        cell.imgView.contentMode = .scaleAspectFit
        cell.imgView.image = photos[indexPath.row]
        return cell
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
