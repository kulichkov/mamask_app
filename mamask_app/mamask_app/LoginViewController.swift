//
//  LoginViewController.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 10/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let mobiquoURL = URL(string: "http://mama26.ru/testapp/mobiquo/mobiquo.php")!
    static let showBoxesIdentifier = "Show Boxes"
}

class LoginViewController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func login(_ sender: UIButton) {
        //DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            self.tapatalk.login(login_name: self.name.text!, password: self.password.text!) { self.loginResults = $0 }
        //}
    }

    let tapatalk = TapatalkAPI(url: Constants.mobiquoURL)
    private var loginResults = [String: Any]() {
        didSet {
            if let loginResult = loginResults["result"] as? Bool {
                if loginResult {
                    performSegue(withIdentifier: Constants.showBoxesIdentifier, sender: self)
                } else {
                    //TODO: Обработка ошибок аутентификации login()
                }
            } else {
                //TODO: Обработка общих ошибок аутентификации
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //tapatalk.logout_user(){ print("User logged out\n\($0)") }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier {
            if segueIdentifier == Constants.showBoxesIdentifier {
                if let btvc = segue.destination as? BoxesTableViewController {
                    //DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    self.tapatalk.get_box_info() {
                        if let messageRoomCount = $0["message_room_count"] as? Int {
                            btvc.messageRoomCount = messageRoomCount
                        }
                        if let boxes = $0["list"] as? [[String: Any?]] {
                            boxes.forEach({ (box) in
                                var newBox = Box()
                                if let unreadCount = box["unread_count"] as? Int {
                                    newBox.unreadCount = unreadCount
                                }
                                if let boxID = box["box_id"] as? String {
                                    newBox.boxID = boxID
                                }
                                if let boxType = box["box_type"] as? String {
                                    newBox.boxType = boxType
                                }
                                if let boxName = box["box_name"] as? String {
                                    newBox.boxName = boxName
                                }
                                if let msgCount = box["msg_count"] as? Int {
                                    newBox.msgCount = msgCount
                                }
                                btvc.boxes.append(newBox)
                            })
                        }
                    //}
                    }
                }
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
