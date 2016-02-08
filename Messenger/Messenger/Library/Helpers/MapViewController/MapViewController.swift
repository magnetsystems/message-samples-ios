//
//  MapViewController.swift
//  MMChat
//
//  Created by Kostya Grishchenko on 1/25/16.
//  Copyright © 2016 Kostya Grishchenko. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var vMap: MKMapView!
    var location: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        vMap.setRegion(coordinateRegion, animated: true)
        
        let annotation = MapPin(coordinate: location)
        vMap.addAnnotation(annotation)

//        vMap.setCenterCoordinate(location, animated: false)
        self.view.sendSubviewToBack(vMap)
    }

    @IBAction func closeAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPin {
            
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")

            view.annotation = annotation
            
            return view
        }
        return nil
    }

}

class MapPin: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
        super.init()
    }
}
