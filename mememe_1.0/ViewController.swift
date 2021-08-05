//
//  ViewController.swift
//  mememe_1.0
//
//  Created by Bruno Pontes Lira on 05/08/21.
//

import UIKit

let defaultTopText = "TOP"
let defaultBottomText = "BOTTOM"

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Variables
    
    //criar Struct para manter a imagem Memed concluída
    struct Meme{
        let topText: String
        let bottomText: String
        let originalImage: UIImage
        let memedImage: UIImage
    }
    @IBAction func test(_ sender: Any) {
        navigationController?.isNavigationBarHidden = true
    }
    
    let memeTextFieldDelegate: UITextFieldDelegate = MemeTextDelegate()
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5.0,
    ]
    
    //MARK: Outlets
    @IBOutlet weak var memePlaceholder: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    //MARK: Actions
    @IBAction func pickAnImageFromAlbum(_ sender: UIBarButtonItem) {
        presentPickerViewController(source: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: UIBarButtonItem) {
        presentPickerViewController(source: .camera)
    }
    
    func presentPickerViewController(source: UIImagePickerController.SourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let meme = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        activityController.completionWithItemsHandler = {
            (activity, completed, items, error) in
            if completed {
                print("test")
                self.save()
            }
        }
        present(activityController, animated: true, completion: nil)
    }
    
    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        setupMemeTextFields(textField: topTextField, defaultTextAttributes: memeTextAttributes, capitalizationType: .allCharacters, defaultText: defaultTopText, textAlignment: .center, textFieldDelegate: memeTextFieldDelegate)
        setupMemeTextFields(textField: bottomTextField, defaultTextAttributes: memeTextAttributes, capitalizationType: .allCharacters, defaultText: defaultBottomText, textAlignment: .center, textFieldDelegate: memeTextFieldDelegate)
        
        if(memePlaceholder.image == nil){
            shareButton.isEnabled = false
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Private Methods
    
    func setupMemeTextFields(textField: UITextField, defaultTextAttributes: [NSAttributedString.Key: Any], capitalizationType: UITextAutocapitalizationType, defaultText: String, textAlignment: NSTextAlignment, textFieldDelegate: UITextFieldDelegate){
        textField.defaultTextAttributes = defaultTextAttributes //Initialize memeTextFieldAttributes
        textField.autocapitalizationType = capitalizationType //Set capitalization of TextFields to All Caps
        textField.text = defaultText //Set initial text for TextFields
        textField.textAlignment = textAlignment //Centre text fields
        textField.delegate = textFieldDelegate //Assign textfield delegate
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if (bottomTextField.isFirstResponder){
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //Tire um instantâneo da visualização atual na tela
    func generateMemedImage() -> UIImage {
        
        //Esconder a barra de navegação e a barra de ferramentas
        navigationController?.isNavigationBarHidden = true
        memeToolbar.isHidden = true
        
        //Renderizar a vista para uma imagem
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //Mostra a barra de navegação e a barra de ferramentas
        navigationController?.isNavigationBarHidden = false
        memeToolbar.isHidden = false

        return memedImage
    }
    
    //Criar meme
    func save() {
            let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memePlaceholder.image!, memedImage: generateMemedImage())
    }
    
    //MARK: UIImagePickerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            memePlaceholder.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

