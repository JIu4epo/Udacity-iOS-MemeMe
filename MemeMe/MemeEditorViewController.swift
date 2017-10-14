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
    
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    var differenceHeight: CGFloat?
    
    var imageViewHeight: CGFloat?
    var imageViewWidth: CGFloat?

    let bottomLabelToImageViewConstaintId = "bottomLabelToImageView"
    let topLabelToImageViewConstaintId = "topLabelToImageView"
    let newTopLabelToImageViewConstaintId = "newTopLabelToImageView"
    let newBottomLabelToImageViewConstaintId = "newBottomLabelToImageView"

    
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

    @IBOutlet weak var topLabelToImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLabelToImageViewConstraint: NSLayoutConstraint!
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.unsubscribeToKeyboardNotifications()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if imageView.image != nil {
            if UIDevice.current.orientation.isLandscape {
                changeVerticalConstraintForLandscape()
            } else {
                changeVerticalConstraintForPortrait()
            }
        }
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
                print("not complited")
                let alert = UIAlertController(title: "Opps... Something wrong", message: "Can't complete image picking", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
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
    
    func changeInitialVerticalConstraint(){
        self.imageViewHeight = self.imageView.bounds.height
        self.imageViewWidth = self.imageView.bounds.width
        
        self.differenceHeight = self.view.bounds.height - self.imageViewHeight!
        
        setNewConstraints()
    }
    
    func changeVerticalConstraintForPortrait(){
        self.imageViewHeight = self.imageView.bounds.width - self.differenceHeight!
        self.imageViewWidth = self.view.bounds.height

        setNewConstraints()
    }
    
    func changeVerticalConstraintForLandscape(){
        self.imageViewHeight = self.imageView.bounds.width
        self.imageViewWidth = self.imageView.bounds.height

       setNewConstraints()
    }
    
    //MARK: Functions
    func setNewConstraints(){
        let imageSize = self.imageView.image!.size
        let scaledImageHeight = min(imageSize.height * (self.imageViewWidth! / imageSize.width), self.imageViewHeight!)
//        let halfImageHeight = scaledImageHeight / 2.0
//        let halfImageViewHeigth = self.imageViewHeight! / 2.0
        
//        let additionalHeightConstraint = halfImageViewHeigth - halfImageHeight
        
        let additionalHeightConstraint = getHeightDifference(scaledImageHeight: scaledImageHeight)
        
        let viewConstraints = self.view.constraints
        for constraint in viewConstraints {
            if (constraint.identifier == topLabelToImageViewConstaintId) || (constraint.identifier == bottomLabelToImageViewConstaintId) || (constraint.identifier == newTopLabelToImageViewConstaintId) || ((constraint.identifier == newBottomLabelToImageViewConstaintId)){
                constraint.isActive = false
            }
        }
        
        let newTopConstraint = NSLayoutConstraint(item: topTextField, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1, constant: additionalHeightConstraint)
        newTopConstraint.identifier = newTopLabelToImageViewConstaintId
        self.view.addConstraint(newTopConstraint)
        
        let newBottomConstraint = NSLayoutConstraint(item: bottomTextField, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: -additionalHeightConstraint)
        newBottomConstraint.identifier = newBottomLabelToImageViewConstaintId
        self.view.addConstraint(newBottomConstraint)
    }
    
    func getHeightDifference(scaledImageHeight: CGFloat) -> CGFloat{
        let halfImageHeight = scaledImageHeight / 2.0
        let halfImageViewHeigth = self.imageViewHeight! / 2.0
        
        return halfImageViewHeigth - halfImageHeight
    }
    
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
        
        if UIDevice.current.orientation == UIDeviceOrientation.portrait || UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            let imageSize = self.imageView.image!.size
            let scaledImageHeight = min(imageSize.height * (self.imageViewWidth! / imageSize.width), self.imageViewHeight!)
            let scaledImageWidth = min(imageSize.width * (self.imageViewHeight! / imageSize.height), self.imageViewWidth!)
            let y = ((self.view.bounds.size.height + UIApplication.shared.statusBarFrame.height) / 2.0) - (scaledImageHeight / 2.0)
            
            let size = CGSize(width: scaledImageWidth, height: scaledImageHeight)
            UIGraphicsBeginImageContext(size)
            UIGraphicsGetCurrentContext()?.translateBy(x: 0, y: -y)
            
            view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
            
            let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return memedImage
        } else {
            let imageSize = self.imageView.image!.size
            let scaledImageHeight = min(imageSize.height * (self.imageViewWidth! / imageSize.width), self.imageViewHeight!) - (topToolbar.frame.size.height + bottomToolbar.frame.size.height)
            let scaledImageWidth = min(imageSize.width * (scaledImageHeight / imageSize.height), self.imageViewWidth!)
            let x = (self.view.bounds.size.width / 2.0) - (scaledImageWidth / 2.0)
            let y = (self.view.bounds.size.height / 2.0) - (scaledImageHeight / 2.0)
            
            let size = CGSize(width: scaledImageWidth, height: scaledImageHeight)
            UIGraphicsBeginImageContext(size)
            UIGraphicsGetCurrentContext()?.translateBy(x: -x, y: -y)
            
            view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
            
            let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return memedImage
        }
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
            changeInitialVerticalConstraint()
//            changeVerticalConstraintForPortrait()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

