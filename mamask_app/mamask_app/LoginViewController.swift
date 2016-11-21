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

class LoginViewController: UIViewController, UITextFieldDelegate {
    var changedY = false
    var viewOffset: CGFloat = 0
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBAction func login(_ sender: UIButton) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            print("starting self.tapatalk.login...")
            self.tapatalk.login(login_name: self.name.text!, password: self.password.text!) { (loginResult, _) in
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardRect.size.height
            let currentTextField = (name.isFirstResponder ? name : password)!
            let highestUserY = currentTextField.convert(currentTextField.bounds.origin, to: self.view).y + currentTextField.bounds.height
            viewOffset = self.view.bounds.height - keyboardHeight - highestUserY - 5.0
            if viewOffset < 0 {
                if (!changedY) {
                    self.view.frame.origin.y += viewOffset
                }
                changedY = true
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if changedY {
            self.view.frame.origin.y -= viewOffset
        }
        changedY = false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name {
            password.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
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
