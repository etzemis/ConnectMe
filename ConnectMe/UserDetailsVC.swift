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
    
    var user: User = User(id: 1 as NSNumber, name: "User 1",
                          destination: Destination(address: "TestAdress 1", region: "TestRegion 1", coord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877)),
                          currentCoord: CLLocationCoordinate2D(latitude: 37.983709, longitude: 23.680877))

    let regionRadius: CLLocationDistance = 500
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //change title of navigation bar
        self.title = user.name
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
        let initialLocation = user.destination.coord
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation,
                                                                  regionRadius * 5.0, regionRadius * 5.0)
        map.setRegion(coordinateRegion, animated: true)
        
        map.addAnnotation(user)
        map.showAnnotations([user], animated: true)
    }
    
    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}
