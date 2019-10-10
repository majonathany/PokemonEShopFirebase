//
//  ItemCollectionViewCell.swift
//  eShop
//
//  Created by Jonathan Ma on 8/24/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit
import Firebase

class ItemCollectionViewCell: UICollectionViewCell
{
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var itemName: UILabel!
  @IBOutlet weak var itemPrice: UILabel!
  @IBOutlet weak var stepper: UIStepper!
  @IBOutlet weak var quantity: UILabel!
  
  @IBAction func valueChanged(_ sender: UIStepper) {
    var amount = Int(sender.value)
    quantity.text = "\(amount)"
    
  }
  
  override func prepareForReuse() {
    imageView.image = nil
  }
}
