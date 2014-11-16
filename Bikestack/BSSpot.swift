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
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    var id: Int
    var capacity: Int
    var rating: Int
    var photoUrl: String
    
    init(jsonDict:NSDictionary) {
        id = jsonDict["id"] as Int
        if let cap = jsonDict["capacity"] as? Int {
            capacity = cap
        }
        else {
            capacity = 1
        }
        coordinate = CLLocationCoordinate2D(latitude: jsonDict["lat"] as Double, longitude: jsonDict["lon"] as Double)
        title = jsonDict["name"] as String
        subtitle = jsonDict["description"] as String
        if let url = jsonDict["url"] as? String {
            if url == "/images/medium/missing.png" {
                photoUrl = ""
            }
            else {
                photoUrl = url
            }
        }
        else {
            photoUrl = ""
        }
        if let r = jsonDict["total_votes"] as? Int {
            rating = r
        }
        else {
            rating = 0
        }
        
        super.init()
    }
    
    init(coord:CLLocationCoordinate2D, name:String, desc:String, cap:Int) {
        coordinate = coord
        title = name
        subtitle = desc
        id = -1
        capacity = cap
        photoUrl = ""
        rating = 0
        super.init()
    }
}
