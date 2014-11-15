//
//  BSSpot.swift
//  Bikestack
//
//  Created by Brice Dobry on 11/14/14.
//  Copyright (c) 2014 obycode. All rights reserved.
//

import Foundation
import MapKit

class BSSpot : NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    let id: Int
    let capacity: Int?
    
    init(jsonDict:NSDictionary) {
        id = jsonDict["id"] as Int
        if (jsonDict.valueForKey("capacity") != nil) {
            capacity = jsonDict["capacity"] as? Int
        }
        coordinate = CLLocationCoordinate2D(latitude: jsonDict["lat"] as Double, longitude: jsonDict["lon"] as Double)
        title = jsonDict["name"] as String
        subtitle = jsonDict["description"] as String
    }
    
    init(coord:CLLocationCoordinate2D, name:String, desc:String, cap:Int) {
        coordinate = coord
        title = name
        subtitle = desc
        id = -1
        capacity = cap
    }
}
