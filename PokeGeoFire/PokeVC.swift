//
//  ViewController.swift
//  PokeGeoFire
//
//  Created by Alex de France on 4/7/18.
//  Copyright © 2018 Def Labs. All rights reserved.
//

import UIKit
import MapKit

class PokeVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locManager = CLLocationManager()
    var mapHasCentered = false
    var geoFire: GeoFire!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }

    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCentered {
                centerMapOnLocation(location: loc)
                mapHasCentered = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotView?.image = #imageLiteral(resourceName: "ash")
        }
        return annotView
    }
    
    @IBAction func spotPoke(_ sender: Any) {
    }
    
}
