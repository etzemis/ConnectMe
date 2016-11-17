//
//  TravellerCell.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 23/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import PINRemoteImage

class TravellerCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var extraPersons: UILabel!
    @IBOutlet weak var proximityImageView: UIImageView!
    @IBOutlet weak var proximityLabel: UILabel!
    
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
    
    private var _proximity: String{
        set{ self.proximityLabel.text = "Prox: \(newValue)"}
        get{ return self._proximity}
    }
    
    
    
    var traveller: Traveller?{
        didSet{
            updateUI()
        }
    }

    func updateUI(){
        self._name = traveller!.name
        self._destination = "\(traveller!.destination.region!), \(traveller!.destination.address!)"
        self._extraPersons = String(traveller!.extraPersons)
        setCircularImage()
        setProximityImage()
        self.accessoryType = .none
        self.selectionStyle = .none
    }
    
    private func setProximityImage(){
        switch traveller!.proximity{
        case 0:
            self.proximityImageView.image =  #imageLiteral(resourceName: "travellerPinHighProximity")
            self._proximity = "1km"
        case 1:
            self.proximityImageView.image =  #imageLiteral(resourceName: "travellerPinMediumProximity")
            self._proximity = "2km"
        default:
            self.proximityImageView.image =  #imageLiteral(resourceName: "travellerPinLowProximity")
            self._proximity = "10km"
        }
        
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
//        } else {
//            self.profileImage.image =  #imageLiteral(resourceName: "empty_profile")
//            self.profileImage.layer.cornerRadius = 32
//            self.profileImage.clipsToBounds = true
//            self.profileImage.layer.borderWidth = 1
//            self.profileImage.layer.borderColor = UIColor.lightGray.cgColor
//        }
        
        
//        self.profileImage.image =  UIImage(named: "empty_profile")
//        self.profileImage.layer.cornerRadius = 32
//        self.profileImage.clipsToBounds = true
//        self.profileImage.layer.borderWidth = 1
//        self.profileImage.layer.borderColor = UIColor.blue.cgColor
    }
}


//    override func setSelected(_ selected: Bool, animated: Bool) {
//////        super.setSelected(selected, animated: animated)
////        if selected{
////            self.backgroundColor = UIColor.blue
////        }
////        else{
////            self.backgroundColor = UIColor.clear
////        }
////        // Configure the view for the selected state
//
