//
//  ViewController.swift
//  ImagePickerExperience
//
//  Created by YoYo on 2021-05-08.
//
protocol image {
    func imagePickerController(String: Any)
}
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    
    //MARK: Overrrides
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        subscribetokeyboardWillHide()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.textFieldSettings(topTextField, text: "TOP")
        self.textFieldSettings(bottomTextField, text: "BOTTOM")
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        unsuscribetokeyboardWillHide()
    }
   

    // MARK: Text Fields
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -2.0
    ]
    
    
    func textFieldSettings(_ textField: UITextField, text: String){
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.textAlignment = .center
        textField.delegate = self
        textField.text = text
        textField.borderStyle = .none
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    
    
    //MARK: Picking Images
    
    func chooseImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    // MARK: Pick Images
    @IBAction func pickFromAlbum(_ sender: Any) {
        chooseImage(source: .photoLibrary)
        
    }
    @IBAction func pickAnImageFromCamera(_sender: Any) {
        chooseImage(source: .camera)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
            if let imageK = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                        imageView.image = imageK
                        picker.dismiss(animated: true, completion: nil)
     
                    }
        }
    
    
    
    // MARK: KeyboardWillShow
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
       
    }
    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder{
        view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    
    
    //MARK: KeyboardWillHide
    @objc func keyboardWillHide(_ notification:Notification) {
    view.frame.origin.y = 0
    }
    func subscribetokeyboardWillHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unsuscribetokeyboardWillHide(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: Saving Memes
    struct Meme {
       var topTextField: String
        var bottomTextField: String
        var imageView: UIImage
        var memedImage: UIImage
    }
    func save(image: UIImage) {
            // Create the meme
        _ = Meme(topTextField: topTextField.text!, bottomTextField: bottomTextField.text!, imageView: imageView.image!, memedImage: image)
    }
    func toolbar(isHidden: Bool){
        topToolBar.isHidden = isHidden
        bottomToolBar.isHidden = isHidden
    }
    func generateMemedImage() -> UIImage {
        toolbar(isHidden: true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        toolbar(isHidden: false)
        return memedImage
    }
   
    //MARK: The buttons in nav bar
    @IBAction func shareImage() {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error -> () in
        if (completed) {
        self.save(image: memedImage)
        activityViewController.dismiss(animated: true, completion: nil)
               }
           }
        self.present(activityViewController, animated: true, completion: nil)
       }
    @IBAction func deleteMeme(_sender: Any){
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imageView.image = nil
    }
    }


