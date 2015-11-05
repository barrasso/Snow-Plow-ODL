//
//  MBSnowAnnotation.swift
//  SnowPlow
//
//  Created by Mark on 11/5/15.
//  Copyright © 2015 MEB. All rights reserved.
//

import UIKit
import MapKit

class MBSnowAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        
        super.init()
    }
    
}
