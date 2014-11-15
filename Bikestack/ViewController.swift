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
let apiGetSpots = "/api/spots" //GET
let apiCreateSpot = "/api/spots"  // POST: lock_up -> (name, lat, lon, description, capacity)
let apiFindSpots = "/api/spots/find" // POST: lat, lon, radius (miles, defaults to .1)

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        var request = HTTPTask()
        request.baseURL = apiBaseUrl

        //The expected response will be JSON and be converted to an object return by NSJSONSerialization instead of a NSData.
        request.responseSerializer = JSONResponseSerializer()
        println("getting spots...")
        request.GET(apiGetSpots, parameters: nil, success: {(response: HTTPResponse) in
            if let spotList = response.responseObject as? Array< Dictionary<String,AnyObject> > {
                self.addPointsFromList(spotList)
            } else {
                println("response was not a dict: \(response)")
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response)")
            })
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: locationManager.location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        let params: Dictionary<String,AnyObject> = ["lat" : locationManager.location.coordinate.latitude, "long" : locationManager.location.coordinate.longitude, "name" : "test spot"]
        
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        
        request.POST(apiCreateSpot, parameters: params, success: {(response: HTTPResponse) in
            println("Got data from \(apiBaseUrl + apiCreateSpot)")
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response)")
        })
    }
    
    @IBAction func centerOnLocation(sender: AnyObject) {
        let region = MKCoordinateRegion(center: locationManager.location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
//        mapView.setCenterCoordinate(locationManager.location.coordinate, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        let location = locations.last as CLLocation
//        
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//        
//        mapView.setRegion(region, animated: true)
    }
    
    func addPointsFromList(list: Array< Dictionary<String,AnyObject> >) {
        println("add points from \(list)")
        for item in list {
            let spot = BSSpot(jsonDict: item)
            mapView.addAnnotation(spot.annotation)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

