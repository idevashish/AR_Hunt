//
//  ARItem.swift
//  AR_Hunt
//
//  Created by Gerald Soriano on 3/6/19.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

struct ARItem {
  let itemDescription: String
  let location: CLLocation
  var itemNode: SCNNode?
}
