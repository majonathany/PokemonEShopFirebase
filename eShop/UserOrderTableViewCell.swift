//
//  UserOrderTableViewCell.swift
//  eShop
//
//  Created by Jonathan Ma on 8/24/17.
//  Copyright © 2017 majonathany. All rights reserved.
//

import UIKit

class UserOrderTableViewCell: UITableViewCell
{
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var totalCostLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
