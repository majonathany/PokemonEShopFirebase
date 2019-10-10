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

class ShoppingCollectionViewController: UICollectionViewController
{
  
  var listOfItems: [String]?
  var handle: AuthStateDidChangeListenerHandle?
  var storage = Storage.storage()
  
  override func viewWillAppear(_ animated: Bool)
  {
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in

      
    }
    
    
  }
  override func viewWillDisappear(_ animated: Bool)
  {
    Auth.auth().removeStateDidChangeListener(handle!)
  }
  
  
  override func viewDidLoad() {
   
    if (listOfItems == nil)
    {
      listOfItems = []
      let pokemonRef = Firestore.firestore().collection("pokemon")
      
      pokemonRef.getDocuments { (querySnapshot, err) in
        if let err = err {
          print("Error getting documents: \(err)")
        }
        else
        {
          for document in querySnapshot!.documents {
            self.listOfItems!.append(document.documentID)
          }
          self.collectionView?.reloadData()
        }
      }
    }
    
    super.viewDidLoad()
    self.collectionView!.alwaysBounceVertical = true
    
    let rc = UIRefreshControl()
    rc.addTarget(self, action: #selector(ShoppingCollectionViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
  }
  
  @objc func handleRefresh(refreshControl: UIRefreshControl)
  {
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
    print("collectionView() is called: \(listOfItems!.count)")

      return listOfItems!.count
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
    
    
    
    let pokemonUID = listOfItems![indexPath.row]
    
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
  
  
  
}


