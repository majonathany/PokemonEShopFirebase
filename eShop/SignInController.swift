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
  }
  

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func signIn(_ sender: UIButton) {
    
    if (Auth.auth().currentUser?.email) != nil
    {
      print(Auth.auth().currentUser?.email)
    }
    guard let email = emailField.text,
      let password = passwordField.text,
      email.count > 0,
      password.count > 0
      else
    {
      return
    }
    Auth.auth().signIn(withEmail: email, password: password)
    { user, error in
      if let error = error, user == nil {
        let alert = UIAlertController(title: "Sign In Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
      }
      else
      {
        self.performSegue(withIdentifier: "loginSegue", sender: nil)
        self.emailField.text = "Email Address"
        self.passwordField.text = "Password"
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
