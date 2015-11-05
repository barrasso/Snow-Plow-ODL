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
    
    /* Annotations */
    let annotationTitles = [
        "Plow 001",
        "Plow 002"]
    
    let annotationCoordinates = [
        CLLocationCoordinate2DMake(40.349774, -74.653205), // Plow 001 on Charlton St
        CLLocationCoordinate2DMake(40.350437, -74.651837)] // Plow 002 on Olden St

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
        self.addAnnotationsToMapView()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func addAnnotationsToMapView() {
        for (var i = 0; i < self.annotationTitles.count; i++) {
            let newAnnotation = MBAnnotation(coordinate: self.annotationCoordinates[i], title: self.annotationTitles[i])
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
        let customReuseID = "marker"
        let anView = mapView.dequeueReusableAnnotationViewWithIdentifier(customReuseID)
        
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