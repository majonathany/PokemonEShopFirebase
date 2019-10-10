//
//  UserOrderTableViewController.swift
//  eShop
//
//  Created by Jonathan Ma on 8/24/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit
import Firebase

class UserOrderTableViewController: UITableViewController
{
  var handle: AuthStateDidChangeListenerHandle?
  
  var orders: [String]?
  
  //Needs user authentication
  override func viewWillAppear(_ animated: Bool) {
    handle = Auth.auth().addStateDidChangeListener { (auth, user) in
      let usersRef = Firestore.firestore().collection("dbUsers")
      
      let userDoc = usersRef.document(user!.uid)
      
      userDoc.getDocument{ (document, error) in
        if let document = document, document.exists {
          self.orders = document.data()!["orders"] as! [String]
        }
        else
        {
          print("Something went wrong - the user is not in the database.")
        }
      }
    }
    
    self.tableView.reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool){
    
    Auth.auth().removeStateDidChangeListener(handle!)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let rc = UIRefreshControl()
    rc.addTarget(self, action: #selector(UserOrderTableViewController.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
    
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
    
    guard let orders = self.orders else
    {
      return 0
    }
    return self.orders!.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cellIdentifier = "UserOrderTableViewCell"
    
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? UserOrderTableViewCell else
    {
      fatalError("Could not load cell")
    }
    
    
    
    let order = orders![indexPath.row]
    
    let ordersRef = Firestore.firestore().collection("orders")
    
    let orderDoc = ordersRef.document(order)
    
    orderDoc.getDocument {(document, error) in
      if let document = document, document.exists {
        
        let timestamp = document.data()!["orderedOn"] as! Timestamp
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM/DD/yyyy"
        
        cell.dateLabel.text = dateformatter.string(from: timestamp.dateValue())
        cell.totalCostLabel.text = "100"
        
      }
    }
    
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
  }
  
  @objc func handleRefresh(refreshControl: UIRefreshControl)
  {
    self.tableView.reloadData()
    refreshControl.endRefreshing()
  }
  
}
