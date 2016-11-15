//
//  StartLoadingViewController.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 15/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import UIKit

private struct Constants {
    static let mobiquoURL = URL(string: "http://mama26.ru/testapp/mobiquo/mobiquo.php")!
    static let showAuthUISegue = "Show Auth UI"
    static let showBoxesUISegue = "Show Boxes UI"
}

class StartLoadingViewController: UIViewController {

    let tapatalk = TapatalkAPI(url: Constants.mobiquoURL)

    private func testingLogin() {
        tapatalk.get_config() { (_, getConfigHTTPResponse) in
            DispatchQueue.main.async { [weak weakSelf = self] in
                print("Checking authorization...\n\(getConfigHTTPResponse)")
                if let mobiquoIsLogin = (getConfigHTTPResponse["Mobiquo_is_login"] as? String)?.toBool() {
                    if mobiquoIsLogin {
                        print("Singing in...")
                        weakSelf?.performSegue(withIdentifier: Constants.showBoxesUISegue, sender: weakSelf)
                    }
                    else {
                        print("Singing failed...")
                        weakSelf?.performSegue(withIdentifier: Constants.showAuthUISegue, sender: weakSelf)
                    }
                } else {
                    print("Singing failed...")
                    weakSelf?.performSegue(withIdentifier: Constants.showAuthUISegue, sender: weakSelf)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        testingLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier {
            if segueIdentifier == Constants.showAuthUISegue {
                // TODO: prepare login UI
            } else if segueIdentifier == Constants.showBoxesUISegue {
                if let boxesTVC = segue.destination.contentViewController as? BoxesTableViewController {
                    boxesTVC.tapatalk = tapatalk
                }
            }
        }
    }

}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
