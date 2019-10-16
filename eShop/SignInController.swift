//
//  ViewController.swift
//  eShop
//
//  Created by Jonathan Ma on 8/21/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit
import ValidationComponents
import Firebase

class SignInController: UIViewController
{
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  var handle: AuthStateDidChangeListenerHandle?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    view.addGestureRecognizer(tap)
    
  }
  @objc func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "loginSegue"
    
    {
      guard let email = emailField.text,
        let password = passwordField.text,
        email.count > 0,
        password.count > 0
        else {
          return false
      }
    }
    return true
  }
  
  @IBAction func signIn(_ sender: Any) {
    Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!)
    { user, error in
      if let error = error, user == nil {
        let alert = UIAlertController(title: "Sign In Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func unwindFromHelp(sender: UIStoryboardSegue)
  {
    
  }
  
  
  
}

extension SignInController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == emailField {
      passwordField.becomeFirstResponder()
    }
    if textField == passwordField {
      textField.resignFirstResponder()
    }
    return true
  }
}
