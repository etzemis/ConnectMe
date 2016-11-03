//
//  DataHolder.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 02/11/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation

class DataHolder{
    static let sharedInstance = DataHolder()
    
    var travellers: [Traveller] = []
    
    // MARK: Load Travellers Remote
    func loadTravellers(){
        ServerAPIManager.sharedInstance.fetchTravellersAroundMe{
            result in
            guard result.error == nil else {
                self.handleLoadTravellersError(result.error!)
                return
            }
            if let fetchedTravellers = result.value {
                self.travellers = fetchedTravellers
            }
        }
    }
    // Handle Load Travellers Error
    func handleLoadTravellersError(_ error: Error) {
        //TODO: Show Error
    }
    
}
