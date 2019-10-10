//
//  CartTableViewCell.swift
//  eShop
//
//  Created by Jonathan Ma on 8/22/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell
{
  @IBOutlet weak var itemImageView: UIImageView!
  @IBOutlet weak var itemName: UILabel!
  @IBOutlet weak var itemQuantity: UILabel!
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
