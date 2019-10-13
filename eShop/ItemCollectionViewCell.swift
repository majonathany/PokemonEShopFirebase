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
  @IBOutlet weak var stepper: UIStepper! {

    didSet {      stepper.addTarget(self, action: #selector(increment), for: .touchUpInside)
      stepper.addTarget(self, action: #selector(decrement), for: .touchUpInside)
    }
  }
  
  var delegate: ItemCollectionViewCellDelegate?
  var itemUID: String?
  
  @IBOutlet weak var quantity: UILabel!

  
  
  @IBAction func valueChanged(_ sender: UIStepper) {
    if sender.value == 1.0{
      self.increment()
    }
    else
    {
      self.decrement()
    }
    
    sender.value = 0
  }
  
  @objc private func increment()
  {
    delegate!.increment(self.itemUID!)
  }
  @objc private func decrement()
  {
    delegate!.decrement(self.itemUID!)
  }
  
  override func prepareForReuse() {
    imageView.image = nil
  }
}
