//
//  TravellerCell.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 23/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import PINRemoteImage

class TravellerStatusCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var extraPersons: UILabel!
    
    @IBOutlet weak var statusUmageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    private var _name: String{
        set{ self.name.text = "\(newValue)"}
        get{ return self._name}
    }
    
    private var _destination: String{
        set{ self.destination.text = "\(newValue)"}
        get{ return self._destination}
    }
    
    private var _extraPersons: String{
        set{ self.extraPersons.text = "Persons: \(newValue)"}
        get{ return self._extraPersons}
    }
    
    
    private var hasAlreadyAccepted: Bool = false
    
    var traveller: Traveller?{
        didSet{
            updateUI()
        }
    }
    
    func setTraveller(traveller: Traveller, hasAlreadyAccepted: Bool)
    {
        self.traveller = traveller
        self.hasAlreadyAccepted = hasAlreadyAccepted
        
    }
    
    func updateUI(){
        self._name = traveller!.name
        self._destination = "\(traveller!.destination.region!), \(traveller!.destination.address!)"
        self._extraPersons = String(traveller!.extraPersons)
        setCircularImage()
        self.accessoryType = .none
        self.selectionStyle = .none
        updateTravellerStatus()
    }
    
    
    private func setCircularImage(){
        let urlString = traveller!.imageUrl
        let url = URL(string: urlString)
        self.profileImage.pin_setImage(from: url, placeholderImage:#imageLiteral(resourceName: "empty_profile")) {
            result in
            self.profileImage.layer.cornerRadius = 32
            self.profileImage.clipsToBounds = true
            self.profileImage.layer.borderWidth = 1
            self.profileImage.layer.borderColor = UIColor.lightGray.cgColor
            self.setNeedsLayout()
            return
        }

    }
    
    private func updateTravellerStatus(){
        
        if !self.hasAlreadyAccepted{
            if let travellerStatus = TripRequestDataHolder.sharedInstance.travellersInInvitationStatus[traveller!.email]
            { //it is not me
                switch travellerStatus {
                case .waiting:
                    self.spinner.startAnimating()
                    self.statusUmageView.image = nil
                    break
                case .accepted:
                   // self.spinner.stopAnimating()
                    self.statusUmageView.image = #imageLiteral(resourceName: "userAccepted")
                    break
                default:
                    //self.spinner.stopAnimating()
                    self.statusUmageView.image = #imageLiteral(resourceName: "userCancelled")
                    break
                }
                
            }
        }
        else{
                // It is the user Logged In
                //self.spinner.stopAnimating()
                self.statusUmageView.image = #imageLiteral(resourceName: "userAccepted")
        }
        
    }

}


