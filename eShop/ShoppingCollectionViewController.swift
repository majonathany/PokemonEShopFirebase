//
//  ShoppingCollectionViewController.swift
//  eShop
//
//  Created by Jonathan Ma on 8/22/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

private let reuseIdentifier = "ItemCollectionViewCell"

class ShoppingCollectionViewController: UICollectionViewController, ItemCollectionViewCellDelegate
{
  var itemsCache: [String]?
  
  var handle: AuthStateDidChangeListenerHandle?
  var storage = Storage.storage()
  var cartDocument: DocumentReference?
  
  let pokemonRef = Firestore.firestore().collection("pokemon")

  let usersRef = Firestore.firestore().collection("dbUsers")
  var userID: String?
  var userDoc: DocumentReference?
  var userData: [String: Any]?
  
  var cartID: String?
  var cartDoc: DocumentReference?
  var cartData: [String: Any]?
  var cartCache: [String: Int]?
  
  override func viewWillAppear(_ animated: Bool)
  {
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      guard let user = user else
      {
        self.dismiss(animated: true)
        return
      }
      
      self.userID = user.uid
      self.userDoc = self.usersRef.document(self.userID!)
      self.userDoc!.getDocument { (userDocument, error) in
        guard let userDocument = userDocument, userDocument.exists else
        {
          let alert = UIAlertController(
            title: "Firebase Problem",
            message: "There is a problem loading the user's document from the database.",
            preferredStyle: .alert)
          
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          
          self.present(alert, animated: true, completion: nil)
          return
        }
        
        self.cartID = userDocument.data()!["cartID"] as? String
        self.cartDoc = Firestore.firestore().collection("carts").document(self.cartID!)
        self.cartDoc!.getDocument{ (cartDocument, cartError) in
          guard let cartDocument = cartDocument, cartDocument.exists else
          {
            self.cartData = [
              "items": [:],
              "postedBy": self.userID!
            ]
            self.cartDoc?.setData(self.cartData!)
            self.cartCache = [:]
            return
          }
          self.cartData = cartDocument.data()
          self.cartCache = self.cartData!["items"] as? [String: Int]
          
        }
      }
    }
  }
  override func viewWillDisappear(_ animated: Bool)
  {
    if self.cartCache != nil
    {
      self.cartDoc!.updateData(["items":
        self.cartCache!])
    }
    Auth.auth().removeStateDidChangeListener(handle!)
  }
  
  
  override func viewDidLoad() {
   
    
    super.viewDidLoad()
    
    self.collectionView!.alwaysBounceVertical = true
    let rc = UIRefreshControl()
    rc.addTarget(self, action: #selector(ShoppingCollectionViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    self.collectionView!.addSubview(rc)
    
    
    self.itemsCache = []
    self.loadData()
  }

  private func loadData()
  {
    pokemonRef.getDocuments { (querySnapshot, err) in
      if let err = err {
        print("Error getting documents: \(err)")
      }
      else
      {
        for document in querySnapshot!.documents {
          self.itemsCache!.append(document.documentID)
        }
        self.collectionView!.reloadData()
      }
    }
  }
  
  @objc func handleRefresh(refreshControl: UIRefreshControl)
  {
    refreshControl.beginRefreshing()
    self.loadData()
    self.collectionView!.reloadData()
    refreshControl.endRefreshing()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  /*
   // MARK: - Navigation
   
   */
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return self.itemsCache!.count
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
    
    let pokemonUID = self.itemsCache![indexPath.row]
    let pokemonRef = Firestore.firestore().collection("pokemon")
    let pokemonDoc = pokemonRef.document(pokemonUID)
    
    pokemonDoc.getDocument{ (document, error) in
      if let document = document, document.exists {
        
        let pokemonDict = document.data()!
        
        cell.itemName.text = pokemonDict["name"] as? String
        cell.itemPrice.text = "Price: $\(pokemonDict["price"] as! Int)"
        cell.quantity.text = "\(0)"
        cell.stepper.stepValue = 1
        cell.stepper.minimumValue = 0
        cell.delegate = self
        cell.itemUID = pokemonDoc.documentID
                
        let pathReference = self.storage.reference(forURL: "\(pokemonDict["imageURL"] as! String)")
                
        pathReference.getData(maxSize: 2*1024*1024)
        { (data, error) in
          if error != nil {
            print(error!.localizedDescription)
            cell.imageView.image = nil
          }
          else
          {
            cell.imageView.image = UIImage(data: data!)
          }
        }
      }
    }
    return cell
  }
  
  func increment(_ uid: String)
  {
    if self.cartCache![uid] != nil
    {
      self.cartCache![uid]! += 1
    }
    else
    {
      self.cartCache![uid] = 1
    }
  }
  
  func decrement(_ uid: String)
  {
    if self.cartCache![uid] == nil
    {
      return
    }
    
    if self.cartCache![uid]! > 0
    {
      self.cartCache![uid]! -= 1
    }
    if self.cartCache![uid]! == 0
    {
      self.cartCache?.removeValue(forKey: uid)
    }
  }
}
