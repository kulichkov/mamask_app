//
//  BoxTableViewController.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 11/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let boxCellReuseIdentifier = "Message Cell"
    static let sentBoxID = "sent"
    static let showFullMessageIdentifier = "Show Full Message"
}


class BoxTableViewController: UITableViewController {


    var tapatalk: TapatalkAPI?
    var boxName = ""
    var boxID = "" {
        didSet {
            getBox()
        }
    }
    private var boxMessages = [BoxMessage]()
    private var totalMessageCount = 0
    private var totalUnreadCount = 0

    struct Recipient {
        let userID: String?
        let username: String
    }

    struct BoxMessage {
        let msgID: String
        let msgState: Int //1 = Unread, 2 = Read;, 3 = Replied;, 4 = Forwarded;
        let timestamp: String?
        let sentDate: Date?
        let msgFromID: String
        let msgFrom: String?
        let iconURL: URL?
        let msgSubject: String?
        let shortContent: String?
        let isOnline: Bool?
        let msgTo: [Recipient]
    }

    private func getBox() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak weakSelf = self] in
            print("Starting tapatalk.get_box()...")
            weakSelf?.tapatalk?.get_box(box_id: weakSelf?.boxID ?? "", start_num: nil, end_num: nil) { (getBoxResult, _) in
                DispatchQueue.main.async {
                    print("Starting handler in get_box...")
                    weakSelf?.totalMessageCount = (getBoxResult["total_message_count"] as? Int) ?? 0
                    weakSelf?.totalUnreadCount = (getBoxResult["total_unread_count"] as? Int) ?? 0
                    if let messages = getBoxResult["list"] as? [[String: Any?]] {
                        weakSelf?.boxMessages = [BoxMessage]()
                        messages.forEach(){ (message) in
                            let msgID = message["msg_id"] as? String ?? ""
                            let msgState = message["msg_state"] as? Int ?? 0
                            let timestamp = weakSelf?.shortTimeStringFrom(Date(timeIntervalSince1970: TimeInterval((Double((message["timestamp"] as? String) ?? "0.0"))!)))
                            let sentDate = message["sent_date"] as? Date
                            let msgFromID = message["msg_from_id"] as? String ?? ""
                            let msgFrom = message["msg_from"] as? String
                            let iconURL = URL(string:((message["icon_url"] as? String) ?? ""))
                            let msgSubject = message["msg_subject"] as? String
                            let shortContent = message["short_content"] as? String
                            let isOnline = message["is_online"] as? Bool
                            var msgTo = [Recipient]()
                            if let recipients = message["msg_to"] as? [[String: Any]] {
                                recipients.forEach(){ (recipient) in
                                    let username = recipient["username"] as? String ?? ""
                                    let userID = recipient["user_id"] as? String
                                    msgTo.append(Recipient(userID: userID, username: username))
                                }
                            }
                            weakSelf?.boxMessages.append(BoxMessage(msgID: msgID, msgState: msgState, timestamp: timestamp, sentDate: sentDate, msgFromID: msgFromID, msgFrom: msgFrom, iconURL: iconURL, msgSubject: msgSubject, shortContent: shortContent, isOnline: isOnline, msgTo: msgTo))

                            weakSelf?.navigationItem.title = weakSelf?.boxName
                            weakSelf?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    private func shortTimeStringFrom(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Date().timeIntervalSince(date) > 24*60*60 {
            formatter.dateStyle = DateFormatter.Style.short
        } else {
            formatter.timeStyle = DateFormatter.Style.short
        }
        return formatter.string(from: date)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return boxMessages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.boxCellReuseIdentifier, for: indexPath)

        let message = boxMessages[indexPath.row]
        if let messageCell = cell as? MessageTableViewCell {
            messageCell.isSentBox = (boxID == Constants.sentBoxID)
            messageCell.message = message
        }

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier {
            if segueIdentifier == Constants.showFullMessageIdentifier {
                if let fmtvc = segue.destination.contentViewController as? FullMessageTableViewController, let selectedBox = sender as? MessageTableViewCell {
                    let indexOfSelected = (tableView.indexPath(for: selectedBox)?.row)!
                    fmtvc.boxID = self.boxID
                    fmtvc.messageID = boxMessages[indexOfSelected].msgID
                    fmtvc.tapatalk = tapatalk
                }
            }
        }
    }
}
