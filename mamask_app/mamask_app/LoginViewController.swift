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
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            print("starting self.tapatalk.login...")
            self.tapatalk.login(login_name: self.name.text!, password: self.password.text!) { loginResult in
                print("Executing handler... loginResults = \(loginResult)")
                DispatchQueue.main.async { self.loginResults = loginResult }
                print("End of handler...") }
        }
    }

    let tapatalk = TapatalkAPI(url: Constants.mobiquoURL)
    private var loginResults = [String: Any]() {
        didSet {
            if let loginResult = loginResults["result"] as? Bool {
                if loginResult {
                    print("Starting performSegue...")
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
                if let btvc = segue.destination.contentViewController as? BoxesTableViewController {
                    btvc.tapatalk = tapatalk
                }
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
