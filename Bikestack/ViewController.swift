//
//  ViewController.swift
//  Bikestack
//
//  Created by Brice Dobry on 11/14/14.
//  Copyright (c) 2014 obycode. All rights reserved.
//

import UIKit
import MapKit

let apiBaseUrl = /*"http://7be16d68.ngrok.com"*/"https://bikestack.herokuapp.com"
let apiGetSpots = "/api/spots" //GET
let apiCreateSpot = "/api/spots"  // POST: ["lock_up": ["name":, "lat":, "lon", "description":, "capacity":]]
let apiFindSpots = "/api/spots/find" // POST: ["lock_up": ["lat":, "lon":, "rad":<miles, defaults to .1>]]
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
        let newSpot = BSSpot(coord: mapView.region.center, name: "", desc: "", cap: 1)
        // -1 is the holder for a new spot
        currentSpots[-1] = newSpot

        dispatch_async(dispatch_get_main_queue(), { self.mapView.addAnnotation(newSpot) })
        
        addSpotDetailView.hidden = false
    }
    
    @IBAction func cancelNewSpot(sender: AnyObject) {
        addSpotDetailView.hidden = true
        addSpotNameField.text = ""
        addSpotNameField.resignFirstResponder()
        addSpotDescriptionField.text = ""
        addSpotDescriptionField.resignFirstResponder()
        let spot = currentSpots[-1]
        currentSpots[-1] = nil
        mapView.removeAnnotation(spot)
    }
    
    @IBAction func addNewSpot(sender: AnyObject) {
        println("add a new spot: \(addSpotNameField.text) \(addSpotDescriptionField.text)")
        let newSpot = currentSpots[-1]!
        newSpot.title = addSpotNameField.text
        newSpot.subtitle = addSpotDescriptionField.text
        let dict: Dictionary<String, AnyObject> = ["lat": newSpot.coordinate.latitude, "lon": newSpot.coordinate.longitude, "name": newSpot.title, "description": newSpot.subtitle, "capacity": newSpot.capacity]
        let params: Dictionary<String, Dictionary<String, AnyObject> > = ["lock_up": dict]
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        
        println("params are \(params)")
        request.POST(apiCreateSpot, parameters: params, success: {(response: HTTPResponse) in
            println("Got data from \(apiBaseUrl + apiCreateSpot)")
            self.getLocalSpots()
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
        let params: Dictionary<String, Dictionary<String, AnyObject> > = ["vote": dict]
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        println("params are \(params)")
        request.POST(apiVote, parameters: params,  success: {(response: HTTPResponse) in
            println("response was \(response.text())")
            dispatch_async(dispatch_get_main_queue(), {
                self.spotDetailRating.text = response.text()
                self.spotDetailRating.setNeedsDisplay()
                let currentRating = response.text()?.toInt()
                if currentRating < 0 {
                    self.spotDetailRating.textColor = UIColor.redColor()
                }
                else if currentRating > 0 {
                    self.spotDetailRating.textColor = UIColor.greenColor()
                }
                else {
                    self.spotDetailRating.textColor = UIColor.blackColor()
                }
            })
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response?.text())")
        })
    }
    
    @IBAction func thumbsDown(sender: AnyObject) {
        let annotations = mapView.selectedAnnotations
        if annotations.count != 1 {
            return
        }
        
        let selectedSpot: BSSpot = mapView.selectedAnnotations[0] as BSSpot
        
        let dict: Dictionary<String, AnyObject> = ["lock_up_id": selectedSpot.id, "direction": "down"]
        let params: Dictionary<String, Dictionary<String, AnyObject> > = ["vote": dict]
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        println("params are \(params)")
        request.POST(apiVote, parameters: params,  success: {(response: HTTPResponse) in
            dispatch_async(dispatch_get_main_queue(), {
                self.spotDetailRating.text = response.text()
                self.spotDetailRating.setNeedsDisplay()
                let currentRating = response.text()?.toInt()
                if currentRating < 0 {
                    self.spotDetailRating.textColor = UIColor.redColor()
                }
                else if currentRating > 0 {
                    self.spotDetailRating.textColor = UIColor.greenColor()
                }
                else {
                    self.spotDetailRating.textColor = UIColor.blackColor()
                }
            })
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response?.text())")
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
    
    func getLocalSpots() {
        var request = HTTPTask()
        request.baseURL = apiBaseUrl
        
        //The expected response will be JSON and be converted to an object return by NSJSONSerialization instead of a NSData.
        request.responseSerializer = JSONResponseSerializer()
        println("getting spots...")
        let dict: Dictionary<String, AnyObject> = ["lat" : locationManager.location.coordinate.latitude, "lon" : locationManager.location.coordinate.longitude, "rad" : (mapView.region.span.latitudeDelta)*69]
        println("latitude Delta is \(mapView.region.span.latitudeDelta)")
        let params: Dictionary<String,Dictionary<String, AnyObject> > = ["lock_up": dict]
        println("params are \(params)")
        request.POST(apiFindSpots, parameters: params, success: {(response: HTTPResponse) in
            //        request.GET(apiGetSpots, parameters: nil, success: {(response: HTTPResponse) in
            if let spotList = response.responseObject as? Array< Dictionary<String,AnyObject> > {
                println("got \(spotList)")
                self.addPointsFromList(spotList)
            } else {
                println("response was not a dict: \(response.text())")
            }
            }, failure: {(error: NSError, response: HTTPResponse?) in
                println("print the error: \(error)")
                println("print the response: \(response?.text())")
        })
    }

    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        // if we haven't already zoomed to the current location, don't get spots yet
        if (!inited) {
            return
        }
        
        getLocalSpots()
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
            }
            else {
                pinView!.annotation = annotation
            }
            let spot = annotation as BSSpot
            if spot.id == -1 {
                pinView!.pinColor = .Purple
                println("set draggable")
                pinView!.draggable = true
            }
            else {
                pinView!.canShowCallout = true
                pinView!.pinColor = .Green
                let calloutBtn = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
                calloutBtn.addTarget(self, action: "showSpotDetails:", forControlEvents: UIControlEvents.TouchUpInside)
                pinView?.rightCalloutAccessoryView = calloutBtn as UIView
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
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.Ending {
            let droppedAt: CLLocationCoordinate2D = view.annotation.coordinate;
            println("setting new coordinates for new point \(droppedAt.latitude)")
            currentSpots[-1]?.coordinate = droppedAt
        }
    }

    func addPointsFromList(list: Array< Dictionary<String,AnyObject> >) {
//        mapView.removeAnnotations(mapView.annotations)
        for item in list {
            let spot = BSSpot(jsonDict: item)
            currentSpots[spot.id] = spot
            dispatch_async(dispatch_get_main_queue(), {
                self.mapView.addAnnotation(spot)
            })
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
        if !selectedSpot.photoUrl.isEmpty {
            var url = NSURL(string: selectedSpot.photoUrl)
            println("getting photo from \(selectedSpot.photoUrl)")
            var image: UIImage?
            var request: NSURLRequest = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                if error == nil {
                    println("got the image!")
                    image = UIImage(data: data)
                    self.spotDetailImageView.image = image
                }
                else {
                    println("error getting the image \(error)")
                }
            })
        }
        else {
            self.spotDetailImageView.image = UIImage(named: "addImage.png")
        }
        spotDetailRating.text = String(selectedSpot.rating)
        if selectedSpot.rating < 0 {
            self.spotDetailRating.textColor = UIColor.redColor()
        }
        else if selectedSpot.rating > 0 {
            self.spotDetailRating.textColor = UIColor.greenColor()
        }
        else {
            self.spotDetailRating.textColor = UIColor.blackColor()
        }
        spotDetailView.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

