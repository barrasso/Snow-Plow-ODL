//
//  MainViewController.swift
//  SnowPlow
//
//  Created by Mark on 11/4/15.
//  Copyright © 2015 MEB. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    /* CLLocation Manager */
    let locationManager = CLLocationManager()
    
    /* Plow Location Timer */
    var plowTimer = NSTimer?()
    
    /* Annotations */
    let plowAnnotationTitles = [
        "Plow 001",
        "Plow 002"]
    
    let plowAnnotationCoordinates = [
        CLLocationCoordinate2DMake(40.349798, -74.655044), // Plow 001 on William St
        CLLocationCoordinate2DMake(40.348995, -74.650696)] // Plow 002 on Prospect Ave
    
    let snowAnnotationTitles = [
        "Washington Rd",
        "Olden St",
        "New street"]
    
    let snowAnnotationSubtitles = [
        "Light Snow - 0.5 m",
        "Heavy Snow - 1.2 m",
        "Mild Snow - 0.75 m"]
    
    let snowAnnotationCoordinates = [
        CLLocationCoordinate2DMake(40.347029, -74.654447), // Snow 001
        CLLocationCoordinate2DMake(40.350437, -74.651837), // Snow 002
        CLLocationCoordinate2DMake(40.357033, -74.664458)] // Snow 003
    

    /* Map View */
    var didLoadMapView = false
    @IBOutlet var plowMapView: MKMapView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        plowMapView = MKMapView()
    }
    
    // MARK: VIEW CONTROLLER OVERRIDES
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // setup map
        self.plowMapView.delegate = self
        
        // check if user is plow
        let checkPlow = NSUserDefaults.standardUserDefaults().boolForKey("isPlow")
        if checkPlow {
            // start updating location
            plowTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updatePlowLocation", userInfo: nil, repeats: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Plow Functions
    
    func updatePlowLocation() {
        let urlString = "http://172.20.10.2:8282/InCSE1/TestAE/TestContainer/Plow001/LocGPS"

        
        // url request properties
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.addValue("application/vnd.onem2m-res+json;ty=4", forHTTPHeaderField: "Content-Type")
        request.addValue("//localhost:10000", forHTTPHeaderField: "X-M2M-Origin")
        request.addValue("12345", forHTTPHeaderField: "X-M2M-RI")
        
        // append user location
        let lat = self.plowMapView.userLocation.coordinate.latitude
        let long = self.plowMapView.userLocation.coordinate.longitude
        let coords = String(format: "%f,%f", lat,long)
        
        // JSON payload
        let params: [NSString : AnyObject] =
        [
            "m2m:cin": [
                "con":coords
                ]
        ]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
        } catch {
            print("did not serialize post")
        }
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            
            do {
                // serialize nsdata to json dict structure
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print("Data: \(jsonDict)")
                
            } catch {
                print("errrrrooorrr")
            }
        })
        
        task.resume()
        
    }
    
    // MARK: LOCATION MANAGER DELEGATE
//    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("my coords: \(self.plowMapView.userLocation.coordinate)")
//    }
    
    // MARK: MAP UTILITY FUNCTIONS
    
    func setCenterOfMapToUserLocation(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        plowMapView.setRegion(region, animated: true)
    }
    
    func addPlowAnnotationsToMapView() {
        for (var i = 0; i < self.plowAnnotationTitles.count; i++) {
            let newAnnotation = MBAnnotation(coordinate: self.plowAnnotationCoordinates[i], title: self.plowAnnotationTitles[i])
            plowMapView.addAnnotation(newAnnotation)
        }
    }
    
    func addSnowAnnotationsToMapView() {
        for (var i = 0; i < self.snowAnnotationTitles.count; i++) {
            let newAnnotation = MBSnowAnnotation(coordinate: self.snowAnnotationCoordinates[i], title: self.snowAnnotationTitles[i], subtitle: self.snowAnnotationSubtitles[i])
            plowMapView.addAnnotation(newAnnotation)
        }
    }
    
    // MARK: MAP VIEW DELEGATE FUNCTIONS
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !didLoadMapView {
            
            // initially center map to user
            self.setCenterOfMapToUserLocation(self.plowMapView.userLocation.coordinate)
            
            // get weather data by location
            getWeatherDataUsingCurrentLocation()
            
            // add annotations to map
            self.addPlowAnnotationsToMapView()
            self.addSnowAnnotationsToMapView()
            
            didLoadMapView = true
        }
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        
        // init location manager
        locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // show user location
        self.plowMapView.showsUserLocation = true
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
            
        } else if (annotation is MBSnowAnnotation) { /* Customize Snow Location Annotation */

            let reuseID = "snow"
            var snowView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            
            if snowView == nil {
                snowView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                snowView!.canShowCallout = true
                snowView!.image = UIImage(named: "snow-marker-icon.png")
            } else {
                snowView!.annotation = annotation
            }
            return snowView
        }
        
        /* Customize MBAnnotations */
        let customReuseID = "plow"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(customReuseID)
        
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: customReuseID)
            anView!.canShowCallout = true
            anView!.rightCalloutAccessoryView = UIButton(type: .InfoDark)
            anView!.rightCalloutAccessoryView!.tintColor = UIColor.blackColor()
            
        } else {
            anView!.annotation = annotation
        }
        
        anView!.image = UIImage(named: "plow-icon.png")
        
        return anView
    }
    
    // MARK: Weather API Utility Functions
    
    func getWeatherDataUsingCurrentLocation() {
        var urlString = "https://api.forecast.io/forecast/e60d6488f5493846412d5e783b0f3926/"
        
        // append user location
        let lat = self.plowMapView.userLocation.coordinate.latitude
        let long = self.plowMapView.userLocation.coordinate.longitude
        let coords = String(format: "%f,%f", lat,long)
        urlString += coords

        
        // url request properties
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        // async call to retrieve weather data
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            
            do {
                // serialize nsdata to json dict structure
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                print("Data: \(jsonDict)")

            } catch {
                print("errrrrooorrr")
            }
        })
        
        task.resume()
    }
}