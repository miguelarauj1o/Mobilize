//
//  RegisterViewController.swift
//  Mobilize
//
//  Created by Miguel Araújo on 11/11/15.
//  Copyright © 2015 Miguel Araújo. All rights reserved.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {
  @IBOutlet var user_username: UITextField!
  @IBOutlet var userName: UITextField!
  @IBOutlet var userEmail: UITextField!
  @IBOutlet var userPassword: UITextField!
  @IBOutlet var signUpButton: UIButton!
  var keyboardVisible : Bool!
  var standardKeyboard : Bool!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self,
      action: "dismissKeyboard")
    
    view.addGestureRecognizer(tapGesture)
    self.userPassword.delegate = self
    self.userPassword.secureTextEntry = true
    self.userPassword.returnKeyType = UIReturnKeyType.Send
  }
  
  
  
  func keyboardWillShow (notification: NSNotification){

    if (self.keyboardVisible!){
      return //just ignore
    }
    
    let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    print(frame.height)
    self.view.layoutIfNeeded()
    UIView.animateWithDuration(0.5, animations: {
      self.view.frame.origin.y -= frame.height
      self.keyboardVisible = true
      
      //self.view.layoutIfNeeded()
      }, completion: nil)
    
    
    
    
  }
  

  
  func keyboardWillHide (notification: NSNotification) {

    if (!self.keyboardVisible!){
      return //just ignore
    }

    
    let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
    print(frame.height)
    self.view.layoutIfNeeded()
    UIView.animateWithDuration(0.5, animations: {
      self.view.frame.origin.y += frame.height
      self.keyboardVisible = false
      
      //self.view.layoutIfNeeded()
      }, completion: nil)
  }
  
  
  
  
  func keyboardDidChange (notification: NSNotification){
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 70/255.0, green: 97/255.0, blue: 157/255.0, alpha: 1.0)
    self.navigationController?.navigationBar.translucent = false
    self.navigationController?.navigationBar.backItem?.title = ""
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.keyboardVisible = false
    
    //No Autocorrect, to correct the bug on the password textfield
    self.user_username.autocorrectionType = UITextAutocorrectionType.No
    self.userEmail.autocorrectionType = UITextAutocorrectionType.No
    self.userName.autocorrectionType = UITextAutocorrectionType.No
    self.userPassword.autocorrectionType = UITextAutocorrectionType.No
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil) //UIKeyboardWillShowNotification
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.tintColor = UIColor(red: 70/255.0, green: 97/255.0, blue: 157/255.0, alpha: 1.0)
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  @IBAction func SignUp(sender: AnyObject) {
    print("Enviando dados para base de dados!")
    let user_username = self.user_username.text
    let nameUser = self.userName.text
    let emailUser = self.userEmail.text
    let password = self.userPassword.text
    
    if ((nameUser?.isEmpty)! || (user_username?.isEmpty)! || (emailUser?.isEmpty)! || (password?.isEmpty)!) {
      let alert = UIAlertController(title: "Alerta!", message: "Todos os campos devem ser preenchidos", preferredStyle: .Alert)
      let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
      alert.addAction(okAction)
      self.presentViewController(alert, animated: true, completion: nil)
      return
    }else {
      
      let newUser : PFUser = PFUser()
      newUser.username = user_username
      newUser.email = emailUser
      newUser.password = password
      
      let profileImage : UIImage = UIImage(named: "perfil")!
      let image = UIImageJPEGRepresentation(profileImage, 1)
      
      let userImage : PFFile = PFFile(data: image!)!
      
      newUser.setObject(userImage, forKey: Constants.PROFILE_PICTURE)
      newUser.setObject(nameUser!, forKey: Constants.FIRST_NAME)
      newUser.setObject(nameUser!, forKey: Constants.LAST_NAME)
      newUser.setObject(nameUser!, forKey: Constants.NAME)
      
      newUser.signUpInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
        if success {
          //Go back to login page, the user must agree in the confirmation link sent to his email
          let alert = UIAlertController(title: "Alerta!", message: "Enviamos um email para você, confirme antes de prosseguir!", preferredStyle: .Alert)
          let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
          alert.addAction(okAction)
          
          self.presentViewController(alert, animated: true, completion: nil)
          
          self.navigationController?.popViewControllerAnimated(true)
        }else {
          let userMessage = error?.localizedDescription
          let alert = UIAlertController(title: "Alerta!", message: userMessage, preferredStyle: .Alert)
          let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
          alert.addAction(okAction)
          
          self.presentViewController(alert, animated: true, completion: nil)
        }
      })
    }
  }
  
  func dismissKeyboard() {
    self.view.endEditing(true)
  }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.userPassword.resignFirstResponder()
    self.SignUp(self)
    return true
  }
}