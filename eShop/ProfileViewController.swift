//
//  ProfileViewController.swift
//  eShop
//
//  Created by Jonathan Ma on 8/22/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit
import Firebase



class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
  //Needs user authentication
  
  var handle: AuthStateDidChangeListenerHandle?
  @IBOutlet weak var signOutButton: UIButton!
  
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var memberSince: UILabel!
  
  override func viewWillDisappear(_ animated: Bool)
  {
    Auth.auth().removeStateDidChangeListener(handle!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      
      if user != nil
      {
        let db = Firestore.firestore()
        let ref = db.collection("dbUsers")
        let userRef = ref.document(user!.uid)
        userRef.getDocument{(document, error) in
          if let document = document, document.exists {
            self.name.text = (document.data()!["firstName"] as? String ?? "No First Name") + " " +
            (document.data()!["lastName"] as? String
              ?? "No Last Name")
            guard let time = document.data()!["createdOn"] as? Timestamp else
            {
              self.memberSince.text = "Current Member"
              return
            }
            self.memberSince.text = "Member Since:  \(self.getDateFromTimeStamp(timeStamp: Double(time.seconds)))"
          }
          else
          {
            self.name.text = "No One Signed In"
            self.memberSince.text = "Never"
          }
        }
      }
      else
      {
        self.dismiss(animated: true)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func changePicture(_ sender: UIButton)
  {
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self
    present(imagePickerController, animated: true, completion: nil)
  }
  
  @IBAction func signOutUser(_ sender: Any)
  {
    do
    {
      try Auth.auth().signOut()
    }
    catch {
      print("\(error)")
    }
    
  }
  
  
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
  {
    guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")}
    
    profileImageView.image = selectedImage
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func unwindFromOrders(sender: UIStoryboardSegue)
  {
    
  }
  
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  func getDateFromTimeStamp(timeStamp : Double) -> String {

      let date = NSDate(timeIntervalSince1970: timeStamp)

      let dayTimePeriodFormatter = DateFormatter()
      dayTimePeriodFormatter.dateFormat = "MMM dd, YYYY"
   // UnComment below to get only time
  //  dayTimePeriodFormatter.dateFormat = "hh:mm a"

      let dateString = dayTimePeriodFormatter.string(from: date as Date)
      return dateString
  }
  
}
