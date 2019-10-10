//
//  CartTableViewController.swift
//  eShop
//
//  Created by Jonathan Ma on 8/22/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class CartTableViewController: UITableViewController
{
  
  var handle: AuthStateDidChangeListenerHandle?
  
  var cartID: String?
  var currentCart: [String: Int]?
  
  let storage = Storage.storage()
  
  override func viewWillDisappear(_ animated: Bool){
    
    Auth.auth().removeStateDidChangeListener(handle!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      self.loadView()
    }
    self.tableView.reloadData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if (currentCart == nil)
    {
      currentCart = [:]
    }
    
    let rc = UIRefreshControl()
    rc.addTarget( self, action: #selector(CartTableViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    self.refreshControl = rc
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentCart!.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as? CartTableViewCell else
    {
        fatalError("There was an error loading the Cart Table View Controller")
    }
    
    let pokemonRef = Firestore.firestore().collection("pokemon")
    for item in self.currentCart!
    {
      let pokemonDoc = pokemonRef.document("item")
      pokemonDoc.getDocument{ (document, error) in
        let name = document?.data()!["name"] as! String
        self.currentCart?[name] = cartDocument.data()!["items"][item] as! Int
      }
    }
    
    
    guard let pokemonUID = currentCart?[indexPath.row] else
    {
      cell.itemName.text = "Cannot display"
      cell.itemImageView.image = nil
      return cell
    }
    
    let pokemonDoc = pokemonRef.document(pokemonUID)
    
    pokemonDoc.getDocument{ (document, error) in
      if let document = document, document.exists {
        cell.itemName.text = document.data()!["name"] as? String
        
        let pathReference = self.storage.reference(withPath:
          document.data()!["imageURL"] as! String)
        
        pathReference.getData(maxSize: 1*1024*1024)
        { (data, error) in
          if error != nil {
            cell.itemImageView.image = nil
          }
          else
          {
            cell.itemImageView.image = UIImage(data: data!)
          }
        }
      }
    }
    return cell
  }
  
  
  @objc func handleRefresh(refreshControl: UIRefreshControl)
  {
    let usersRef = Firestore.firestore().collection("dbUsers")
    guard let userID = Auth.auth().currentUser?.uid else
    {
      let alert = UIAlertController(title: "User Problem",
                                    message: "There is no user logged in. Your cart will not be saved.",
                                    preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      
      self.present(alert, animated: true, completion: nil)
      return
    }
    let userDoc = usersRef.document(userID)
    userDoc.getDocument { (document, error) in
      guard let document = document, document.exists else
      {
        let alert = UIAlertController(title: "Firebase Problem",
                                      message: "There is a problem loading the user's document from the database.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
        return
      }
      let cartID = document.data()!["cartID"] as! String
      
      let cartsRef = Firestore.firestore().collection("carts")
      
      let cartDoc = cartsRef.document(cartID)
      cartDoc.getDocument{ (cartDocument, cartError) in
        guard let cartDocument = cartDocument, cartDocument.exists else
        {
        }
        {
          self.currentCart = cartDocument.data()!["items"] as? [String]
        }
      }
    }
    

    
    self.tableView.reloadData()
    refreshControl.endRefreshing()
  }
  
  /*
   // MARK: - Navigation
   */
  
  func getTotalFromCart() -> Double
  {
    let pokemonRef = Firestore.firestore().collection("pokemon")
    
    var sum = 0.0
    for pokemonUID in currentCart!
    {
      let pokemonDoc = pokemonRef.document(pokemonUID)
      
      pokemonDoc.getDocument{ (document, error) in
        if let document = document, document.exists
        {
          sum += document.data()!["price"] as! Double
        }
      }
    }
    return sum
  }
  
  @IBAction func purchase(_ sender: UIBarButtonItem)
  {
    //MARK: Schema
    
    if currentCart!.count < 1
    {
      let alertController = UIAlertController(title: "Failure", message: "You do not have any items in your cart currently.", preferredStyle: .alert)
      let OKAction = UIAlertAction(title: "OK", style: .default)
      
      alertController.addAction(OKAction)
      self.present(alertController, animated: true)
      return
    }
    
    
    //Order Schema
    let order: [String: Any] =
      ["fulfilled": false,
       "orderedBy": Auth.auth().currentUser!.uid,
       "orderedOn": Timestamp(date: Date()),
       "totalCost": getTotalFromCart(),
       "items": currentCart!
    ]
    
    let orderRef = Firestore.firestore().collection("orders")
    
    orderRef.addDocument(data: order)
    
    let cartsRef = Firestore.firestore().collection("carts")
    
    let cartDoc = cartsRef.document(self.cartID!)
    
    cartDoc.updateData([
      "items": []
    ]) { err in
      if let err = err {
        let alertController = UIAlertController(title: "Success", message: "The cart has now become empty.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
        return
      }
      else
      {
        let alertController = UIAlertController(title: "Failure", message: "The system failed to empty your cart after your last purchase.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
        return
      }
    }
    
    
    let alertController = UIAlertController(title: "Successful", message: "You successfully made the purchase for $\(getTotalFromCart())!", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default)
    
    alertController.addAction(OKAction)
    self.present(alertController, animated: true)
    self.currentCart = nil
    
    
  }
  
  
}
