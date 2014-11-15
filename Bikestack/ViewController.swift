//
//  ViewController.swift
//  Bikestack
//
//  Created by Brice Dobry on 11/14/14.
//  Copyright (c) 2014 obycode. All rights reserved.
//

import UIKit
import MapKit

let apiBaseUrl = "https://bikestack.herokuapp.com"
let apiGetSpots = "/spots"
let apiCreateSpot = "/lock_up/submit"

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        // 1
        let location = CLLocationCoordinate2D(
        latitude: 39.275177,
        longitude: -76.5910142
        )
        // 2
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        //3
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = "Advertising.com"
        annotation.subtitle = "3 racks outside"
        */
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization() //requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        //        let spot = BSSpot(lat: 39.275177, long: -76.5910142, name: "Advertising.com")
        
        let dict = ["lat": 39.275177, "lon": -76.5910142, "name": "Advertising.com"]
        let spot = BSSpot(jsonDict: dict)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: spot.annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        //        mapView.setUserTrackingMode(MKUserTrackingMode.FollowWithHeading, animated: true)
        //        mapView.setRegion(<#region: MKCoordinateRegion#>, animated: <#Bool#>)
        
        mapView.addAnnotation(spot.annotation)
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        println("submit is pressed")
        //        let url = NSURL(string: apiBaseUrl + createSpot)
        //        NSLog("url is %@", url!)
        //        let request = NSMutableURLRequest(URL: url!)
        //        let bodyDict = ["lat" : locationManager.location.coordinate.latitude, "long" : locationManager.location.coordinate.longitude, "name" : "test spot"]
        //        let body = NSJSONSerialization.dataWithJSONObject(bodyDict, options: NSJSONWritingOptions(), error: nil)
        //        let task = NSURLSession.sharedSession().uploadTaskWithRequest(request,
        //            fromData: body)
        //        task.resume()
        //        println("posted a spot")
        
        let params: Dictionary<String,AnyObject> = ["lat" : locationManager.location.coordinate.latitude, "long" : locationManager.location.coordinate.longitude, "name" : "test spot"]
        //        var request = HTTPTask()
        //        request.POST(apiBaseUrl + createSpot, parameters: params, success: {(response: HTTPResponse) -> Void in
        //            },failure: {(error: NSError, response: HTTPResponse?) -> Void in
        //        })
        
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        //        request.GET("/users", parameters: ["key": "value"], success: {(response: HTTPResponse) in
        //            println("Got data from http://api.someserver.com/1/users")
        //            },failure: {(error: NSError, response: HTTPResponse?) in
        //                println("print the error: \(error)")
        //        })
        
        request.POST(apiCreateSpot, parameters: params, success: {(response: HTTPResponse) in
            println("Got data from \(apiBaseUrl + createSpot)")
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

