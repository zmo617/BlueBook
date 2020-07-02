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

class AddObjectVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var coverImgView: UIImageView!
    @IBOutlet weak var titleTxtField: UITextField!
    
    
    @IBOutlet weak var addPicBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    //MARK:LOCAL PROPERTIES
    var groupTableDelegate: UIViewController!
    //speech rec
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var speechTask: SFSpeechRecognitionTask!
    var isRecording: Bool = false
    var imgURL: URL!
    
    var editingObject: Bool!
    var editingTitle: String = ""
    var editingContent: String = ""
    var editingImgPath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (editingObject) {
            saveBtn.isHidden = false
            createBtn.isHidden = true
            titleTxtField.text = editingTitle
            contentTxtView.text = editingContent
            let storageRef = Storage.storage().reference()
            let imgRef = storageRef.child(editingImgPath)
            coverImgView.sd_setImage(with: imgRef)
        } else {
            saveBtn.isHidden = true
            createBtn.isHidden = false
        }
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
    @IBAction func importImg(_ sender: Any) {
        let imgPickerController = UIImagePickerController()
        imgPickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imgPickerController.sourceType = .camera
                self.present(imgPickerController, animated: true, completion: nil)
            }else{
                print("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (action: UIAlertAction) in
            imgPickerController.sourceType = .photoLibrary
            self.present(imgPickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //upload image from memory
    func uploadImgToStorage(imgURL: URL, imgRef: String){
        let storageRef = Storage.storage().reference()
        //let data = Data()//from memory
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
    
    //info is a dictionary containing img data.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //old name: info[UIImagePickerControllerOriginalImage]
        let img = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        coverImgView.image = img
        self.imgURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //create button pressed
    @IBAction func createObject(_ sender: Any) {
        let groupVC = groupTableDelegate as! GroupTableVC
        let title = titleTxtField.text!
        let imgPath = "/images/\(title)/cover"
        
        groupVC.addObject(newCoverImgPath: imgPath, newTitle: title, newContent: contentTxtView.text)
        //upload img to Firebase storage
        if let url = self.imgURL{
            uploadImgToStorage(imgURL: url, imgRef: imgPath)
        }
    }
    
    @IBAction func saveObject(_ sender: Any) {
        let groupVC = groupTableDelegate as! ShowObjectVC
        let title = titleTxtField.text!
        let imgPath = "/images/\(title)/cover"
        
        groupVC.editObject(newCoverImgPath: imgPath, newTitle: title, newContent: contentTxtView.text)
        //upload img to Firebase storage
        if let url = self.imgURL{
            uploadImgToStorage(imgURL: url, imgRef: imgPath)
        }
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
