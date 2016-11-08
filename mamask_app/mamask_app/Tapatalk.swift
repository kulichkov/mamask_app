//
//  Tapatalk.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 03/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import Foundation
import wpxmlrpc

class TapatalkAPI {
    //MARK: - Constants

    //MARK: - Variables
    var mobiquoURL: URL?

    //MARK: - Forum

    func get_config() -> [String: Any] {
        return sendURLRequestWithMethod("get_config", andParameters: nil)
    }

    /*
     FORUM SECTION

     get_forum
     get_participated_forum
     mark_all_as_read
     login_forum
     get_id_by_url
     get_board_stat
     get_forum_status
     get_smilies
     */


    private func sendURLRequestWithMethod(_ methodName: String, andParameters parameters: [Any]?) -> [String: Any] {
        var outputParameters = [String: Any]()
        let urlRequest = NSMutableURLRequest(url: mobiquoURL!)
        urlRequest.httpMethod = "POST"
        let encoder = WPXMLRPCEncoder(method: methodName, andParameters: parameters)
        do {
            urlRequest.httpBody = try encoder?.dataEncoded()
        } catch let error {
            print("Error in encoder?.dataEncoded: \(error)")
        }
        let sessionWithoutADelegate = URLSession(configuration: .default)
        let request = urlRequest as URLRequest
        sessionWithoutADelegate.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error in sessionWithoutADelegate.dataTask: \(error)")
            } else if let response = response, let decoder = WPXMLRPCDecoder(data: data) {
                if !decoder.isFault() {
                    print("RESPONSE:\n\(response)")
                    print("DATA_FROM_SERVER:\n\(decoder.object())\nEND DATA\n")
                    if var theDictionary = decoder.object() as? Dictionary<String, Any> {
                        for (key, value) in theDictionary {
                            if let data = value as? Data {
                                if let newValue = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                                    theDictionary.updateValue(newValue, forKey: key)
                                }
                            }
                        }
                        outputParameters = theDictionary
                    }
                } else {
                    print("Response in decoder contains a XML-RPC error")
                }
            }
        }).resume()

        return outputParameters
        
    }
    
    
    
    //MARK: - User


    /*
     USER SECTION
     
     avatar.php
     login
     get_inbox_stat
     logout_user
     get_online_users
     get_user_info
     get_user_topic
     get_user_reply_post
     get_recommended_user
     search_user
     ignore_user
     update_signature
     */
    
}
