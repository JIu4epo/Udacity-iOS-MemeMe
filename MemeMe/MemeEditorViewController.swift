//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Borys Tkachenko on 9/29/17.
//  Copyright © 2017 Borys Tkachenko. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    var defaultTopText: String = "TOP TEXT"
    var defaultBottomText: String = "BOTTOM TEXT"
    let textFieldMaxLength = 35
    let textFieldMinFontSize: CGFloat = 10
    var imageIsLoaded: Bool = false
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3,
        ]
    
    //MARK: Outlets
    @IBOutlet weak var imageFromCameraButton: UIBarButtonItem!
    @IBOutlet weak var imageFromAlbumButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!

    
    //MARK: View overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextField(topTextField)
        prepareTextField(bottomTextField)
        reset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        imageFromCameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        //        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }
    
    //MARK: Actions
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pick(sourceType: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pick(sourceType: .camera)
    }
    
    @IBAction func shareMeme(){
        let controller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                print("Not complited")
                return
            } else {
                print("Complited")
            }
            self.save()
//            self.resetToDefault()
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func resetToDefault(){
        reset()
//        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: Keyboard movement
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        self.view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //MARK: Functions
    func pick(sourceType: UIImagePickerControllerSourceType){
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        self.present(controller, animated: true, completion: nil)

    }
    
    func save() {
        let meme = Meme(
            topText: topTextField.text!,
            bottomText: bottomTextField.text!,
            originalImage: imageView.image!,
            memedImage: generateMemedImage()
        )
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        print("==",appDelegate.memes.count)
    }
    
    func prepareTextField(_ textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.clear
        textField.delegate = self
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = textFieldMinFontSize
        textField.textAlignment = .center
    }
    
    private func reset(){
        topTextField.text = defaultTopText
        bottomTextField.text = defaultBottomText
        imageView.image = nil
        imageIsLoaded = false
        shareButton.isEnabled = false
    }
    
    func generateMemedImage() -> UIImage {
        hideShowBar(hidden: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
//        UIGraphicsBeginImageContext(self.imageView.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideShowBar(hidden: false)
        return memedImage
    }
    
    func hideShowBar(hidden: Bool){
        topToolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }
    
    //MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if  textField.text == defaultBottomText || textField.text == defaultTopText {
            textField.text = ""
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == bottomTextField {
            self.subscribeToKeyboardNotifications()
        } else {
            unsubscribeToKeyboardNotifications()
        }
        if imageIsLoaded {
            return true
        } else {
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text
        return (text?.characters.count)! <= textFieldMaxLength
    }
    
    //MARK: UIImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.shareButton.isEnabled = true
            imageIsLoaded = true
            imageView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

