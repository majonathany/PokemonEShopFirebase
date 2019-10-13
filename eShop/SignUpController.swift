//
//  SignUpControllerViewController.swift
//  eShop
//
//  Created by Professional on 10/6/19.
//  Copyright © 2019 majonathany. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
  
  //MARK: Properties
  
  
  @IBOutlet weak var signupUsername: UITextField!
  @IBOutlet weak var signUpPassword: UITextField!
  @IBOutlet weak var signupConfirmPassword: UITextField!
  @IBOutlet weak var firstName: UITextField!
  @IBOutlet weak var lastName: UITextField!
  
  var handle: AuthStateDidChangeListenerHandle?
  
  override func viewWillDisappear(_ animated: Bool){
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    
    // Do any additional setup after loading the view.
  }
  
  @IBAction func cancel(_ sender: Any) {
    self.dismiss(animated: true)
  }
  
  
  @IBAction func signUp(_ sender: Any)
  {
    if signUpPassword.text! != signupConfirmPassword.text!
    {
      let alert = UIAlertController(title: "Sign Up Alert",
                                    message: "Your two passwords do not match. Please try again.",
                                    preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      self.present(alert, animated: true, completion: nil)
      
      return
    }
    
    Auth.auth().createUser(
      withEmail: signupUsername.text!,
      password: signUpPassword.text!)
    { authResult, error in
      
      guard let user = authResult?.user, error == nil else
      {
        let alert = UIAlertController(title: "Sign Up Alert",
                                      message: error?.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
        
        return
      }

      
      //MARK: Schema
      
      //carts Schema
      let cartSchema: [String: Any] =
        [
          "items": [],
          "postedBy": user.uid
      ]
      
      let cartsRef = Firestore.firestore().collection("carts")
      let createdCart = cartsRef.addDocument(data: cartSchema)
      
      //dbUsers Schema
      
      let userSchema: [String: Any] =
        [
          "cartID": createdCart.documentID,
          "createdOn": Timestamp(date: Date()),
          "email": user.email ?? NSNull(),
          "firstName": self.firstName!.text ?? NSNull(),
          "lastName": self.lastName!.text ?? NSNull(),
          "orders": []
      ]
      
      let usersRef = Firestore.firestore().collection("dbUsers")
      usersRef.document(user.uid).setData(userSchema)
      
      let alert = UIAlertController(title: "Congratulations",
                                    message: "You successfully created an account. Please login.",
                                    preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .default) {(_) in self.dismiss(animated:true)})

      self.present(alert, animated: true)
    }
  }
  
}
