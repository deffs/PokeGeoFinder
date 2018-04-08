//
//  ViewController.swift
//  PokeGeoFire
//
//  Created by Alex de France on 4/7/18.
//  Copyright © 2018 Def Labs. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class PokeVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locManager = CLLocationManager()
    var mapHasCentered = false
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        geoFireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
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
        let annoId = "Pokemon"
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotView?.image = #imageLiteral(resourceName: "ash")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoId) {
            annotView = deqAnno
            annotView?.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoId)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotView = av
        }
        
        if let annotationView = annotView, let anno = annotation as? PokeAnnot {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pokeNumber)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(#imageLiteral(resourceName: "location-map-flat"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotView
    }
    
    func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int) {
        geoFire.setLocation(location, forKey: "\(pokeId)")
        
    }
    
    func showSightingsOnMap(location: CLLocation) {
        let circleQ = geoFire!.query(at: location, withRadius: 2.5)
        _ = circleQ.observe(GFEventType.keyEntered, with: {
            (key, location) in
                let anno = PokeAnnot(coordinate: location.coordinate, pokeNumber: Int(key)!)
                self.mapView.addAnnotation(anno)
        })
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showSightingsOnMap(location: loc)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let  anno = view.annotation as? PokeAnnot {
            let place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "Pokemon Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    @IBAction func spotPoke(_ sender: Any) {
        let loc  = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let rand = arc4random_uniform(151) + 1
        createSighting(forLocation: loc, withPokemon: Int(rand))
    }
    
}

