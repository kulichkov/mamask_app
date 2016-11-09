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
    //MARK: - Variables
    var mobiquoURL: URL?

    //MARK: - Requesting
    private func sendURLRequestWithMethod(_ methodName: String, andParameters parameters: [Any]?, andHandler handler: @escaping tptlkHandler) {
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
                    print("RAW_DATA_FROM_SERVER:\n\(decoder.object())\nEND DATA\n")
                    if var theDictionary = decoder.object() as? Dictionary<String, Any> {
                        for (key, value) in theDictionary {
                            if let data = value as? Data {
                                if let newValue = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                                    theDictionary.updateValue(newValue, forKey: key)
                                }
                            }
                        }
                        handler(theDictionary)
                    }
                } else {
                    print("Response in decoder contains a XML-RPC error")
                }
            }
        }).resume()
    }

    //MARK: - Forum
    typealias tptlkHandler = ([String: Any]) -> Void

    /*
     This function is always the first function to invoke when the app attempts to enter a specific forum. 
     It returns configuration name/value pair for this forum system. There are two kind of name/value pairs. 
     One is those based on some of the forum system configuration, and one is a simple name/value pairs declared in the config.txt file, 
     usually located in mobiquo/conf/config.txt. E.g. the "guest_okay" is based on the forum system configuration. 
     while the "api_level" is mobiquo
    */
    func get_config(handler: @escaping tptlkHandler) {
        return sendURLRequestWithMethod("get_config", andParameters: nil, andHandler: handler)
    }

    func get_forum(handler: @escaping tptlkHandler) {

    }

    func get_participated_forum(handler: @escaping tptlkHandler) {

    }

    func mark_all_as_read(handler: @escaping tptlkHandler) {

    }

    func login_forum(handler: @escaping tptlkHandler) {

    }

    func get_id_by_url(handler: @escaping tptlkHandler) {

    }

    func get_board_stat(handler: @escaping tptlkHandler) {

    }

    func get_forum_status(handler: @escaping tptlkHandler) {

    }

    func get_smilies(handler: @escaping tptlkHandler) {

    }
    
    
    //MARK: - User

    /*
     
     TODO: Разобраться с сохранением кукисов из http-заголовка ответа

     Server returns cookies in HTTP header. 
     Client should store the cookies and pass it back to server for all subsequence calls to maintain user session. 
     ** DO NOT include HTTP Cookies in the request header **
     

     	byte[]	yes		3
     password	byte[]	yes	The app should send the encrypted password to the server if there is instruction received from get_config. Otherwise send the plain-text password. For example most of the vBulletin systems requires md5 encryption by default, while SMF systems support SHA-1 encryption.	3
     anonymous	Boolean		API Level 4 only. Allow user to login anonymously so the user does not appear in the Who's Online list. Useful for background login such as pulling unread PM etc.
     */
    func login(login_name: String, password: String, anonymous: Bool?, handler: @escaping tptlkHandler) {
        let dataLogin = login_name.data(using: String.Encoding.utf8)
        let dataPassword = password.data(using: String.Encoding.utf8)
        return sendURLRequestWithMethod("login", andParameters: [dataLogin!, dataPassword!], andHandler: handler)
    }

    /*
     USER SECTION
     
     avatar.php

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
