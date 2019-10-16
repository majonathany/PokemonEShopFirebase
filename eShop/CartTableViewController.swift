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
  
  @IBOutlet weak var totalCostLabel: UILabel!
  var handle: AuthStateDidChangeListenerHandle?
  let pokemonRef = Firestore.firestore().collection("pokemon")
  
  var userID: String?
  var userDoc: DocumentReference?
  var userData: [String: Any]?
  
  var cartID: String?
  var cartDoc: DocumentReference?
  var cartData: [String: Any]?
  var cartCache: [String: Int]?
  
  let usersRef = Firestore.firestore().collection("dbUsers")
  let storage = Storage.storage()
  
  override func viewWillDisappear(_ animated: Bool){
    
    Auth.auth().removeStateDidChangeListener(handle!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      
      if let user = user
      {
        self.userID = user.uid
        self.userDoc = Firestore.firestore().collection("dbUsers").document(self.userID!)
        self.userDoc!.getDocument { (userDocument, error) in
          guard let userDocument = userDocument, userDocument.exists else
          {
            let alert = UIAlertController(title: "Firebase Problem",
                                          message: "There is a problem loading the user's document from the database.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alert, animated: true, completion: nil)
            return
          }
          self.userData = userDocument.data()
          self.cartID = userDocument.data()!["cartID"] as? String
          self.cartDoc = Firestore.firestore().collection("carts").document(self.cartID!)
          
          self.cartDoc!.getDocument{ (cartDocument, error) in
            guard let cartDocument = cartDocument, cartDocument.exists else
            {
              self.cartData = [
                "items": [],
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
      else
      {
        self.dismiss(animated: true)
      }
      

    }
    self.loadView()
    self.tableView.reloadData()
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let rc = UIRefreshControl()
    rc.addTarget( self, action: #selector(CartTableViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    self.refreshControl = rc
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.cartCache != nil
    {
      return self.cartCache!.count
    }
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as? CartTableViewCell else
    {
      fatalError("There was an error loading the Cart Table View Controller")
    }
    
    if self.cartCache == nil
    {
      cell.itemImageView.image = nil
      cell.itemName.text = "Blank Item"
      cell.itemQuantity.text = "0"
      return cell
    }
    
    let pokemonUID = Array(self.cartCache!.keys)[indexPath.row]
    let pokemonDoc = self.pokemonRef.document(pokemonUID)
    
    pokemonDoc.getDocument{ (pokemonDocument, error) in
      if let pokemonDocument = pokemonDocument, pokemonDocument.exists {
        cell.itemName.text = pokemonDocument.data()!["name"] as? String
        
        cell.itemQuantity.text = "\(self.cartCache![pokemonUID]!)"
        
        let pathReference = self.storage.reference(withPath:
          pokemonDocument.data()!["imageURL"] as! String)
        
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
    self.refreshControl?.beginRefreshing()
    self.cartDoc!.getDocument{ (cartDocument, cartError) in
      guard let cartDocument = cartDocument, cartDocument.exists else
      {
        let alert = UIAlertController(title: "Cart Problem",
                                      message: "There is a problem loading the user's cart from the database.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
        return
      }
      self.cartData = cartDocument.data()
      self.cartCache = self.cartData!["items"] as? [String: Int]

      
      
    }
    
    refreshControl.endRefreshing()
  }
  
  /*
   // MARK: - Navigation
   */
  
  
  @IBAction func purchase(_ sender: UIBarButtonItem)
  {
    //MARK: Schema
    
    
    if self.cartCache!.count == 0
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
       "orderedBy": self.userID!,
       "orderedOn": Timestamp(date: Date()),
       "items": self.cartCache!
    ]
    
    let orderRef = Firestore.firestore().collection("orders")
    let orderDoc = orderRef.addDocument(data: order)
    
    let cartsRef = Firestore.firestore().collection("carts")
    let cartDoc = cartsRef.document(self.cartID!)
    
    cartDoc.updateData([
      "items": [:]
    ]) { err in
      guard let err = err else {
        
        
        let alertController = UIAlertController(title: "Status Message", message: "There has been no change in the cart. No action was taken.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
        return
      }
      let alertController = UIAlertController(title: "Failure", message: "The system failed to empty your cart after your last purchase.", preferredStyle: .alert)
      let OKAction = UIAlertAction(title: "OK", style: .default)
      alertController.addAction(OKAction)
      self.present(alertController, animated: true)
      return
    }
    let alertController = UIAlertController(title: "Successful", message: "You successfully made the purchase!", preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default)
    
    alertController.addAction(OKAction)
    self.present(alertController, animated: true)
    
    self.userDoc!.updateData(["orders": FieldValue.arrayUnion([orderDoc.documentID])])
    self.tableView.reloadData()
    
    
  }
  
  
}
