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
    //MARK: - Variables and utilities
    typealias tptlkHandler = ([String: Any]) -> Void
    var mobiquoURL: URL?

    init(url: URL) {
        mobiquoURL = url
    }
    private func utf8EncodeFromString(_ string: String?) -> Data? {
        return string?.data(using: String.Encoding.utf8)
    }

    private func utf8Decode(_ value: Any) -> Any {
        if let data = value as? Data {
            //print("trying to decode Data {\(value)}...")
            if let newValue = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String {
                return newValue
            }
        } else if var dictionary = value as? [String: Any] {
            //print("trying to decode Dictionary {\(dictionary)}...")
            dictionary.forEach({ (key, valueForKey) in
                dictionary.updateValue(utf8Decode(valueForKey), forKey: key)
            })
            return dictionary
        } else if let array = value as? [Any] {
            //print("trying to decode Array {\(array)}...")
            return array.map { utf8Decode($0) }
        }
        //print("trying return Value {\(value)} as is...")
        return value
    }

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
            } else if let _ = response, let decoder = WPXMLRPCDecoder(data: data) {
                //TODO: Разобраться с response: нужен он нам или нет
                if !decoder.isFault() {
                    print("RESPONSE:\n\(response)\nEND_RESPONSE")
                    print("RAW_DATA_FROM_SERVER:\n\(decoder.object())\nEND DATA\n")
                    if let theDictionary = decoder.object() as? [String: Any] {
                        handler(self.utf8Decode(theDictionary) as! [String: Any])
                        print("Decoded successfully...")
                    }
                } else {
                    print("Response in decoder contains a XML-RPC error")
                }
            }
        }).resume()
    }

    //MARK: - Forum

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


     Server returns cookies in HTTP header. 
     Client should store the cookies and pass it back to server for all subsequence calls to maintain user session. 
     ** DO NOT include HTTP Cookies in the request header **
     

     	byte[]	yes		3
     password	byte[]	yes	The app should send the encrypted password to the server if there is instruction received from get_config. Otherwise send the plain-text password. For example most of the vBulletin systems requires md5 encryption by default, while SMF systems support SHA-1 encryption.	3
     anonymous	Boolean		API Level 4 only. Allow user to login anonymously so the user does not appear in the Who's Online list. Useful for background login such as pulling unread PM etc.
     */
    func login(login_name: String, password: String, anonymous: Bool? = nil, handler: @escaping tptlkHandler) {
        //TODO: Разобраться в LOGIN с сохранением кукисов из http-заголовка ответа
        return sendURLRequestWithMethod("login", andParameters: [utf8EncodeFromString(login_name)!, utf8EncodeFromString(password)!], andHandler: handler)
    }

    func logout_user(handler: @escaping tptlkHandler) {
        return sendURLRequestWithMethod("logout_user", andParameters: nil, andHandler: handler)
    }

    /*
     USER SECTION
     
     avatar.php
     get_inbox_stat
     get_online_users
     get_user_info
     get_user_topic
     get_user_reply_post
     get_recommended_user
     search_user
     ignore_user
     update_signature
     */

    //MARK: - Private message
    /*
     This section provides necessary functions related to private messaging such ability to send/reply/delete/forward private messages. 
     This set of API supports traditional inbox/sent items messaging with multiple folders support.
     
     report_pm
     get_box
     get_quote_pm
     delete_message
     mark_pm_unread
     mark_pm_read

     */

    func create_message(user_name: [String], subject: String?, text_body: String?, action: Int?, pm_id: String?, handler: @escaping tptlkHandler) {
        let encodedUserName = user_name.map{utf8EncodeFromString($0)}
        let encodedSubject = utf8EncodeFromString(subject)
        let encodedTextBody = utf8EncodeFromString(text_body)
        var inputParameters: [Any] = [encodedUserName, encodedSubject ?? "", encodedTextBody ?? ""]
        if action != nil {
            inputParameters.append(action!)
        }
        if pm_id != nil {
            inputParameters.append(pm_id!)
        }
        return sendURLRequestWithMethod("create_message", andParameters: inputParameters, andHandler: handler)
    }

    //Returns a list of message boxes and their information. 
    //It allows the app to support multiple folders beyond Inbox and Sent box.
    func get_box_info(handler: @escaping tptlkHandler) {
        return sendURLRequestWithMethod("get_box_info", andParameters: nil, andHandler: handler)
    }

    //Returns a list of message subject and short content from a specific box.
    func get_box(box_id: String, start_num: Int?, end_num: Int?, handler: @escaping tptlkHandler) {
        var inputParameters: [Any] = [box_id]
        if start_num != nil {
            inputParameters.append(start_num!)
        }
        if end_num != nil {
            inputParameters.append(end_num!)
        }
        return sendURLRequestWithMethod("get_box", andParameters: inputParameters, andHandler: handler)
    }

    //Returns content of private message given a box id and message id
    func get_message(message_id: String, box_id: String, return_html: Bool = false, handler: @escaping tptlkHandler) {
        let inputParameters: [Any] = [message_id, box_id, return_html]
        return sendURLRequestWithMethod("get_message", andParameters: inputParameters, andHandler: handler)
    }

}
