//
//  NetworkingVC.swift
//  ConnectMe
//
//  Created by Evangelos Tzemis on 31/10/16.
//  Copyright © 2016 etzemis. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class NetworkingVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
    }

}




// MARK: Get Post Delete Requests

//        //Get Request
//        Alamofire.request(TodoRouter.get(1))
//            .responseJSON { response in
//                // check for errors
//                guard response.result.error == nil else {
//                    // got an error in getting the data, need to handle it
//                    print("error calling GET on /todos/1")
//                    print(response.result.error!)
//                    return
//                }
//                // make sure we got some JSON since that's what we expect
//                guard let json = response.result.value as? [String: Any] else {
//                    print("didn't get todo object as JSON from API")
//                    print("Error: \(response.result.error)")
//                    return
//                }
//                // get and print the title
//                guard let todoTitle = json["title"] as? String else {
//                    print("Could not get todo title from JSON")
//                    return
//                }
//                print("The title is: " + todoTitle)
//        }
//
//        //Post Request
//        let newTodo: [String: Any] = ["title": "My First Post", "completed": 0, "userId": 1]
//        Alamofire.request(TodoRouter.create(newTodo))
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    // got an error in getting the data, need to handle it
//                    print("error calling POST on /todos/1")
//                    print(response.result.error!)
//                    return
//                }
//                // make sure we got some JSON since that's what we expect
//                guard let json = response.result.value as? [String: Any] else {
//                    print("didn't get todo object as JSON from API")
//                    print("Error: \(response.result.error)")
//                    return
//                }
//                // get and print the title
//                guard let todoTitle = json["title"] as? String else {
//                    print("Could not get todo title from JSON")
//                    return
//                }
//                print("The title is: " + todoTitle)
//        }
//
//        //Delete Request
//        Alamofire.request(TodoRouter.delete(1))
//            .responseJSON { response in
//                guard response.result.error == nil else {
//                    // got an error in getting the data, need to handle it
//                    print("error calling DELETE on /todos/1")
//                    print(response.result.error!)
//                    return
//                }
//                print("DELETE ok")
//        }
