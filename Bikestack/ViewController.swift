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
let apiCreateSpot = "/api/spots"  // POST: ["lock_up": ["name":, "lat":, "lon", "description":, "capacity"]]
let apiFindSpots = "/api/spots/find" // POST: ["lat":, "lon":, "radius":<miles, defaults to .1>]
let apiVote = "/api/spots/vote" // POST: ["vote": ["lock_up_id":"1","direction":"up"]]

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var spotDetailView: UIView!
    @IBOutlet weak var spotDetailTitle: UILabel!
    @IBOutlet weak var spotDetailSubtitle: UILabel!
    @IBOutlet weak var spotDetailRating: UILabel!
    @IBOutlet weak var spotDetailImageView: UIImageView!
    @IBOutlet weak var addSpotDetailView: UIView!
    @IBOutlet weak var addSpotNameField: UITextField!
    @IBOutlet weak var addSpotDescriptionField: UITextView!

    
    var locationManager: CLLocationManager!
    var currentSpots = [Int: BSSpot]() //: Dictionary<Int, BSSpot>
    var inited: Bool!
    
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
        
        inited = false
        
        spotDetailView.layer.cornerRadius = 8
        addSpotDetailView.layer.cornerRadius = 8
        addSpotDescriptionField.layer.borderColor = UIColor.lightGrayColor().CGColor
        addSpotDescriptionField.layer.borderWidth = 1.0
        addSpotDescriptionField.layer.cornerRadius = 8
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        
        let newSpot = BSSpot(coord: locationManager.location.coordinate, name: "", desc: "", cap: 1)
        // -1 is the holder for a new spot
        currentSpots[-1] = newSpot
        
        mapView.addAnnotation(newSpot)
        
        addSpotDetailView.hidden = false
    }
    
    @IBAction func cancelNewSpot(sender: AnyObject) {
        addSpotDetailView.hidden = true
        addSpotNameField.text = ""
        addSpotNameField.resignFirstResponder()
        addSpotDescriptionField.text = ""
        addSpotDescriptionField.resignFirstResponder()
        currentSpots[-1] = nil
    }
    
    @IBAction func addNewSpot(sender: AnyObject) {
        println("add a new spot: \(addSpotNameField.text) \(addSpotDescriptionField.text)")
        let newSpot = currentSpots[-1]!
        newSpot.title = addSpotNameField.text
        newSpot.subtitle = addSpotDescriptionField.text
        let dict: Dictionary<String, AnyObject> = ["lat": newSpot.coordinate.latitude, "lon": newSpot.coordinate.longitude, "name": newSpot.title, "description": newSpot.subtitle, "capacity": newSpot.capacity]
        let params: Dictionary<String, AnyObject> = ["lock_up": dict]
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        
        println("params are \(params)")
        request.POST(apiCreateSpot, parameters: params, success: {(response: HTTPResponse) in
            println("Got data from \(apiBaseUrl + apiCreateSpot)")
            },failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response)")
        })
        
        mapView.removeAnnotation(newSpot)
        
        // Clear the input fields
        addSpotDetailView.hidden = true
        addSpotNameField.text = ""
        addSpotNameField.resignFirstResponder()
        addSpotDescriptionField.text = ""
        addSpotDescriptionField.resignFirstResponder()
    }
    
    @IBAction func centerOnLocation(sender: AnyObject) {
        let region = MKCoordinateRegion(center: locationManager.location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
//        mapView.setCenterCoordinate(locationManager.location.coordinate, animated: true)
    }
    
    @IBAction func thumbsUp(sender: AnyObject) {
        let annotations = mapView.selectedAnnotations
        if annotations.count != 1 {
            return
        }
        
        let selectedSpot: BSSpot = mapView.selectedAnnotations[0] as BSSpot
        
        let dict: Dictionary<String, AnyObject> = ["lock_up_id": selectedSpot.id, "direction": "up"]
        let params: Dictionary<String, AnyObject> = ["vote": dict]
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        //The expected response will be JSON and be converted to an object return by NSJSONSerialization instead of a NSData.
        request.responseSerializer = JSONResponseSerializer()
        println("params are \(params)")
        request.POST(apiVote, parameters: params,  success: {(response: HTTPResponse) in
            if let voteDict = response.responseObject as? Dictionary<String,AnyObject> {
                self.spotDetailRating.text = voteDict["rating"] as? String
            } else {
                println("response was not a dict: \(response)")
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response)")
        })
    }
    
    @IBAction func thumbsDown(sender: AnyObject) {
        let annotations = mapView.selectedAnnotations
        if annotations.count != 1 {
            return
        }
        
        let selectedSpot: BSSpot = mapView.selectedAnnotations[0] as BSSpot
        
        let dict: Dictionary<String, AnyObject> = ["lock_up_id": selectedSpot.id, "direction": "down"]
        let params: Dictionary<String, AnyObject> = ["vote": dict]
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        //The expected response will be JSON and be converted to an object return by NSJSONSerialization instead of a NSData.
        request.responseSerializer = JSONResponseSerializer()
        println("params are \(params)")
        request.POST(apiVote, parameters: params,  success: {(response: HTTPResponse) in
            if let voteDict = response.responseObject as? Dictionary<String,AnyObject> {
                self.spotDetailRating.text = voteDict["rating"] as? String
            } else {
                println("response was not a dict: \(response)")
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response)")
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        // Center to current location on first launch
        if (!inited) {
            inited = true
            
            let location = locations.last as CLLocation
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            
            mapView.setRegion(region, animated: false)
        }
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        // if we haven't already zoomed to the current location, don't get spots yet
        if (!inited) {
            return
        }
        
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        
        //The expected response will be JSON and be converted to an object return by NSJSONSerialization instead of a NSData.
        request.responseSerializer = JSONResponseSerializer()
        println("getting spots...")
        let dict: Dictionary<String, AnyObject> = ["lat" : locationManager.location.coordinate.latitude, "lon" : locationManager.location.coordinate.longitude, "rad" : (mapView.region.span.latitudeDelta)*69]
        println("latitude Delta is \(mapView.region.span.latitudeDelta)")
        let params: Dictionary<String,AnyObject> = ["lock_up": dict]
        println("params are \(params)")
        request.POST(apiFindSpots, parameters: params, success: {(response: HTTPResponse) in
            if let spotList = response.responseObject as? Array< Dictionary<String,AnyObject> > {
                self.addPointsFromList(spotList)
            } else {
                println("response was not a dict: \(response)")
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response)")
        })
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        else if annotation is BSSpot {
            let reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                let spot = annotation as BSSpot
                if spot.id == -1 {
                    pinView!.pinColor = .Purple
                }
                else {
                    pinView!.canShowCallout = true
                    pinView!.pinColor = .Green
                    let calloutBtn = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
                    calloutBtn.addTarget(self, action: "showSpotDetails:", forControlEvents: UIControlEvents.TouchUpInside)
                    pinView?.rightCalloutAccessoryView = calloutBtn as UIView
                }
            }
            else {
                pinView!.annotation = annotation
            }
        
            return pinView
        }

        let reuseId = "newpin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinColor = .Purple
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        spotDetailView.hidden = true
    }

    func addPointsFromList(list: Array< Dictionary<String,AnyObject> >) {
        // TODO: Need to get rid of old spots??
//        mapView.removeAnnotations(currentSpots)
        for item in list {
            let spot = BSSpot(jsonDict: item)
            currentSpots[spot.id] = spot
            mapView.addAnnotation(spot)
        }
    }
    
    func showSpotDetails(sender: UIButton!) {
        let annotations = mapView.selectedAnnotations
        if annotations.count != 1 {
            return
        }
        
        let selectedSpot: BSSpot = mapView.selectedAnnotations[0] as BSSpot
        
        spotDetailTitle.text = selectedSpot.title
        spotDetailSubtitle.text = selectedSpot.subtitle
        spotDetailImageView = UIImageView(image: UIImage(named: "exampleBikeRack.jpg"))
//        spotDetailRating.text = selectedSpot.rating
        spotDetailView.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

