//
//  ItemCollectionViewCellDelegate.swift
//  eShop
//
//  Created by Professional on 10/11/19.
//  Copyright © 2019 majonathany. All rights reserved.
//

import UIKit

protocol ItemCollectionViewCellDelegate: ShoppingCollectionViewController {
  func increment(_ uid: String)
  func decrement(_ uid: String)
}
