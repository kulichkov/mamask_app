//
//  FullMessageTableViewController.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 11/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import UIKit

class FullMessageTableViewController: UITableViewController {
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var fullTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!

    var tapatalk: TapatalkAPI? {
        didSet {
            getFullMessage()
        }
    }

    var boxID = ""
    var messageID = ""

    var message: FullMessage?

    struct Recipient {
        let userID: String?
        let username: String
    }

    struct Attachment {
        let filename: String
        let filesize: Int
        let contentType: String
        let url: URL
        let thumbnailURL: URL?
    }

    struct FullMessage {
        let msgID: String
        let msgState: Int //1 = Unread, 2 = Read;, 3 = Replied;, 4 = Forwarded;
        let timestamp: String?
        let sentDate: Date?
        let msgFromID: String
        let msgFrom: String?
        let iconURL: URL?
        let allowSmilies: Bool?
        let msgSubject: String?
        let textBody: String?
        let isOnline: Bool?
        let msgTo: [Recipient]
        let attachments: [Attachment]?
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

    private func getFullMessage() {
        print("Starting tapatalk.get_message()...")
        tapatalk?.get_message(message_id: messageID, box_id: boxID) { (getMessageResult, _) in
            DispatchQueue.main.async { [weak weakSelf = self] in
                print("Starting handler in get_message...")
                let msgID = getMessageResult["msg_id"] as? String ?? ""
                let msgState = getMessageResult["msg_state"] as? Int ?? 0
                let timestamp = weakSelf?.shortTimeStringFrom(Date(timeIntervalSince1970: TimeInterval((Double((getMessageResult["timestamp"] as? String) ?? "0.0"))!)))
                let sentDate = getMessageResult["sent_date"] as? Date
                let msgFromID = getMessageResult["msg_from_id"] as? String ?? ""
                let msgFrom = getMessageResult["msg_from"] as? String
                let iconURL = URL(string:((getMessageResult["icon_url"] as? String) ?? ""))
                let msgSubject = getMessageResult["msg_subject"] as? String
                let allowSmilies = getMessageResult["allow_smilies"] as? Bool
                let textBody = getMessageResult["text_body"] as? String
                let isOnline = getMessageResult["is_online"] as? Bool
                var msgTo = [Recipient]()
                if let recipients = getMessageResult["msg_to"] as? [[String: Any]] {
                    recipients.forEach(){ (recipient) in
                        let username = recipient["username"] as? String ?? ""
                        let userID = recipient["user_id"] as? String
                        msgTo.append(Recipient(userID: userID, username: username))
                    }
                }
                var attachments = [Attachment]()
                if let files = getMessageResult["attachments"] as? [[String: Any?]] {
                    files.forEach(){ (file) in
                        let filename = file["filename"] as? String ?? ""
                        let filesize = file["filesize"] as? Int ?? 0
                        let contentType = file["content_type"] as? String ?? ""
                        let url = URL(string: (file["url"] as? String ?? ""))!
                        let thumbnailURL = URL(string: (file["thumbnail_url"] as? String ?? ""))
                        attachments.append(Attachment(filename: filename, filesize: filesize, contentType: contentType, url: url, thumbnailURL: thumbnailURL))
                    }
                }
                weakSelf?.message = FullMessage(msgID: msgID, msgState: msgState, timestamp: timestamp, sentDate: sentDate, msgFromID: msgFromID, msgFrom: msgFrom, iconURL: iconURL, allowSmilies: allowSmilies, msgSubject: msgSubject, textBody: textBody, isOnline: isOnline, msgTo: msgTo, attachments: attachments)
                weakSelf?.updateUI()
            }
        }
    }

    private func updateUI() {
        senderLabel.text = nil
        recipientsLabel.text = nil
        subjectLabel.text = nil
        fullTextLabel.text = nil
        timestampLabel.text = nil

        senderLabel.text = message?.msgFrom
        var recipientsArray = message?.msgTo
        var recipients = ((recipientsArray?.removeFirst())?.username)!
        recipientsArray?.forEach({ (recipient) in
            recipients.append(", \(recipient.username)")
        })
        recipientsLabel.text = recipients
        subjectLabel.text = message?.msgSubject
        fullTextLabel.text = message?.textBody
        timestampLabel.text = message?.timestamp

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false


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
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
