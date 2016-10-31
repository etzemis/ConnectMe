//
//  ToDo+Networking.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 31/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import Foundation
import Alamofire

extension Todo{
    

    convenience init?(json: [String: Any]) {
        guard let title = json["title"] as? String,
            let userId = json["userId"] as? Int,
            let completed = json["completed"] as? Bool
            else {
                return nil
            }
        // Since it is optional, unwrap it later
        let idValue = json["id"] as? Int
        
        // Use existing initializer
        self.init(title: title, id: idValue, userId: userId, completedStatus: completed)
    }
    
    func toJSON() -> [String: Any] {
        var json = [String: Any]()
        
        json["title"] = title
        // It is optional
        if let id = id {
            json["id"] = id
        }
        
        json["userId"] = userId
        json["completed"] = completed
        
        return json
    }
    

    class func todoById(id: Int, completionHandler: @escaping (Result<Todo>) -> Void) {
        enum BackendError: Error {
            case objectSerialization(reason: String)
        }
        
        //Get Request
        Alamofire.request(TodoRouter.get(id))
            .responseJSON { response in
                // check for errors from responseJSON 
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /todos/\(id)")
                    print(response.result.error!)
                    completionHandler(.failure(response.result.error!))
                    return
                }
                // make sure we got a JSON dictionary
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get todo object as JSON from API")
                    completionHandler(.failure(BackendError.objectSerialization(reason:"Did not get JSON dictionary in response")))
                    return
                }
                // turn JSON in to Todo object
                guard let todo = Todo(json: json) else {
                    completionHandler(.failure(BackendError.objectSerialization(reason:"Could not create Todo object from JSON")))
                    return
                }
                completionHandler(.success(todo))
        }
    }
}
