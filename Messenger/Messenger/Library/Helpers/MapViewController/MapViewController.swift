/*
* Copyright (c) 2015 Magnet Systems, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you
* may not use this file except in compliance with the License. You
* may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
* implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

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
