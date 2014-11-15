//
//  BSSpot.swift
//  Bikestack
//
//  Created by Brice Dobry on 11/14/14.
//  Copyright (c) 2014 obycode. All rights reserved.
//

import Foundation
import MapKit

class BSSpot {
    let annotation: MKPointAnnotation
    
    init(lat:Double, long:Double, name:String) {
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = name
    }
    
    init(jsonDict:NSDictionary) {
        let location = CLLocationCoordinate2D(latitude: jsonDict["lat"] as Double, longitude: jsonDict["lon"] as Double)
        annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = jsonDict["name"] as String
    }
}
