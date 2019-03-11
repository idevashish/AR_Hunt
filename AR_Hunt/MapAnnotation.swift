//
//  MapAnnotation.swift
//  AR_Hunt
//
//  Created by Gerald Soriano on 3/11/19.
//  Copyright © 2019 Razeware LLC. All rights reserved.
//

import MapKit

class MapAnnotation: NSObject, MKAnnotation {
  let coordinate: CLLocationCoordinate2D
  let title: String?
  let item: ARItem
  
  init(location: CLLocationCoordinate2D, item: ARItem) {
    self.coordinate = location
    self.item = item
    self.title = item.itemDescription
    
    super.init()
  }
}
