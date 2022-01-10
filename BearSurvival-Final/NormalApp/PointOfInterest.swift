//
//  PointOfInterest.swift
//  BearSurvival_v1
//
//  Created by Jordy Fox Bach on 11/7/21.
//

import Foundation
import MapKit

class PointOfInterest: NSObject, MKAnnotation {
    
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
    }
    
    var subtitle: String? {
        return locationName
    }
}
