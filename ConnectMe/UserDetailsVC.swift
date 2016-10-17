//
//  UserDetailsVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 13/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import MapKit

class UserDetailsVC: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var map: MKMapView!{
        didSet {
           setUpMap()
        }
    }
    
    var user: User? = nil
    // MARK: Constants
    private struct Constants{
        static let AnnotationViewReuseIdentifier = "user destination"
        static let CellIdentifier = "UserDetailCell"
        static let RegionRadius: CLLocationDistance = 1500
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //change title of navigation bar
        self.title = user!.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: MKMapViewDelegate
    func setUpMap() {
        map.mapType = .standard
        map.showsUserLocation = false
        map.delegate = self
        let initialLocation = user!.destination.coord
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation,
                                                                  Constants.RegionRadius * 2.0, Constants.RegionRadius * 2.0)
        map.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation
        annotation.title = user!.destination.address
        annotation.subtitle = user!.destination.region
        map.addAnnotation(annotation)
    }
    
    // Implement Delegate Method to Change Pin Color
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annot = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
        annot.pinTintColor = UIColor.black
        annot.canShowCallout = true
        return annot
    }
    
    
    
    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section + 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dequed = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)
        
        if let cell = dequed as? UserDetailCell{
            switch indexPath.section {
            case 0:
                cell.LeftLabel?.text = "Name:"
                cell.RightLabel?.text = self.user?.name
            case 1:
                if indexPath.row == 0 {
                    cell.LeftLabel?.text = "Address:"
                    cell.RightLabel?.text = self.user?.destination.address
                }
                else{
                cell.LeftLabel?.text = "Region:"
                cell.RightLabel?.text = self.user?.destination.region
                }
            default:
                break
            }
        }
        return dequed
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0: return "Profile"
            case 1: return "Destination"
            default:
                print("Wrong Section number")
                return nil
        }
    }

}
