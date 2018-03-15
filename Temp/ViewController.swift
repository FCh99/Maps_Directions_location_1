//
//  ViewController.swift
//  Temp
//
//  Created by Fausto Checa on 14/3/18.
//  Copyright © 2018 Fausto Checa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


// mapa con location y puntos de interés con un botón
// escojo un punto y me sale la ruta desde la location

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var searchString = "hospital"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()  // needs to conform to info.plist
        locationManager.startUpdatingLocation()
        
        
    }
    
    // MARK: - CLLocationManagerDelegate search for multiple "restaurante" or similar and add Annotation to map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Location and region to fit map into
        let location = locations.first
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        let region = MKCoordinateRegionMake(myLocation, span)
        self.mapView.setRegion(region, animated: true)
        
        self.mapView.showsUserLocation = true
        
        // build request
        let request = MKLocalSearchRequest()
        
        request.region = region
        request.naturalLanguageQuery = searchString
        let search = MKLocalSearch(request: request)
        
        //  search start
        search.start { (response, error) in
            guard let response = response else { return }
            let mapItems = response.mapItems
            
            for mapItem in mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    // MARK: -mapView Delegate:  draw route direction from view to user location
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let locationDestination = view.annotation {
             let request = MKDirectionsRequest()
            request.source = MKMapItem.forCurrentLocation()
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: (locationDestination.coordinate)))
            request.transportType = .walking
            request.requestsAlternateRoutes = true
            
            let directions = MKDirections.init(request: request)
            
            directions.calculate { (response, error) in
                if !(error == nil) {
                    print(error as Any)
                }
                guard let response = response else { return }
                
                // clean Map
                let overlays = mapView.overlays
                mapView.removeOverlays(overlays)
                
                // Draw directions
                let myRoute = response.routes[0]
                let overlay = myRoute.polyline
                self.mapView.add(overlay, level: .aboveRoads)
            }
        }
    }
    
   // needed for drawing in the map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKPolyline {
            let r = MKPolylineRenderer(polyline:overlay)
            r.strokeColor = UIColor.blue.withAlphaComponent(1)
            r.lineWidth = 3
            return r
        }
        return MKOverlayRenderer()
    }
    
    
}



