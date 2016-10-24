//
//  TravellerCell.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 23/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit

class TravellerCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var extraPersons: UILabel!
    
    private var _name: String{
        set{ self.name.text = "User: \(newValue)"}
        get{ return self._name}
    }
    
    private var _destination: String{
        set{ self.destination.text = "Dest: \(newValue)"}
        get{ return self._destination}
    }
    
    private var _extraPersons: String{
        set{ self.extraPersons.text = "Persons: \(newValue)"}
        get{ return self._extraPersons}
    }

    func initCell(withTraveller traveller: User){
        self._name = traveller.name
        self._destination = "\(traveller.destination.region), \(traveller.destination.address)"
        self._extraPersons = "1"
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
