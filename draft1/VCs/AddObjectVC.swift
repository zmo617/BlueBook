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
    @IBOutlet weak var titleLabel: UILabel!
    
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
    //for uploading
    var uploadCount: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get object
        if (editingObject) {
            titleTxtField.text = objectPath[2]
            contentTxtView.text = editingContent
            
            //load images
            let imgsRef = self.storageRef.child("/images/\(self.objectPath[0])/\(self.objectPath[1])/\(self.objectPath[2])")
            imgsRef.listAll{(result, error) in
                if error != nil{
                    Styling.errorAlert(vc: self, msg: "Error getting imgs from Firebase: \(error!.localizedDescription)")
                }else{
                    result.items.forEach{(imgRef) in
                        imgRef.getData(maxSize: 1*2000*2000){(data, error) in
                            if error != nil{
                                print("Error getting this img's data:\(error!.localizedDescription)")
                            }else{
                                self.photos.append(UIImage(data: data!)!)
                                self.photoBook.reloadData()
                            }
                        }
                    }
                }
            }
        }
        photoBook.delegate = self
        photoBook.dataSource = self
        
        //Styling
        photoBook.backgroundColor = .clear
        photoBook.backgroundView = nil
        photoBook.layer.borderColor = UIColor.white.cgColor
        photoBook.layer.borderWidth = 1
        
        if (UserDefaults.standard.bool(forKey: "isDarkMode")) {
            titleLabel.textColor = .white
            contentTxtView.textColor = .white
            Styling.styleTextField(titleTxtField)
            Styling.styleFilledButton(addPicBtn, 20)
            Styling.styleFilledButton(recordBtn, 20)
            Styling.styleHollowButton(createBtn, 20)
            bgView = Styling.setUpBg(vc: self, imgName: "bg6")
            Styling.navDarkMode(vc: self)
        } else {
            titleLabel.textColor = .black
            contentTxtView.textColor = .black
            Styling.dayFilledButton(addPicBtn, 20)
            Styling.dayFilledButton(recordBtn, 20)
            Styling.dayHollowButton(createBtn, 20)
            bgView = Styling.setUpBg(vc: self, imgName: "bg5")
            Styling.navDayMode(vc: self)
        }
    }
    
    override func loadView() {
        super.loadView()
        setupView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        photoBook.reloadData()
    }
    
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
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized{
                //call startRecognition
                do {
                    try self.startRecognition()
                } catch let error {
                    print("There was a problem starting recording: \(error.localizedDescription)")
                }
            }else{
                Styling.errorAlert(vc: self, msg: "Disabling speech recognition.")
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
                })
            }
        }
    }
    
    @IBAction func importImg(_ sender: Any) {
        let vc = BSImagePickerViewController()
        vc.navigationBar.tintColor = .appBlue
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
    }
    
    //upload image from memory. imgRef: path name
    func uploadImgToStorage(imgURL: URL, imgRef: String){
        let ref = storageRef.child(imgRef)
        _ = ref.putFile(from: imgURL, metadata: nil){(metadata, error) in
            guard metadata != nil else{
                //has an error
                print(error!.localizedDescription)
                return
            }
            self.uploadCount -= 1
        }
    }
    
    //create button pressed
    @IBAction func createObject(_ sender: Any) {
        objTitle = titleTxtField.text!
        let newContent = contentTxtView.text!
        //upload imgs
        if uploadCount < 0 {
            DispatchQueue.global(qos: .userInteractive).async{
                let downloadGroup = DispatchGroup()
                self.uploadCount = self.selectedAssets.count
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
        }
        
        if self.coverImgPath == nil || self.uploadCount > 0{
            let controller = UIAlertController(title: "Save later", message: "Please wait a sec for image to upload and save again.", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(controller, animated: true, completion: nil)
        }else{
            if self.editingObject {
                let showVC = self.showVCDelegate as! ShowObjectVC
                showVC.editObject(newCoverImgPath: self.coverImgPath, newTitle: self.objTitle, newContent: newContent)
                showVC.backFromEdit = true
            }else{
                let groupVC = self.groupTableDelegate as! GroupTableVC
                groupVC.addObject(newCoverImgPath: self.coverImgPath, newTitle: self.objTitle, newContent: newContent)
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
}
