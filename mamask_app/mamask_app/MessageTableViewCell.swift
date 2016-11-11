//
//  MessageTableViewCell.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 11/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    var isSentBox: Bool?
    var message: BoxTableViewController.BoxMessage? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var shortMessage: UILabel!

    private func updateUI() {
        // clear all fields
        sender.text = nil
        date.text = nil
        subject.text = nil
        shortMessage.text = nil

        //load new information (if any)
        if let message = self.message {
            if isSentBox! {
                var recipientsArray = message.msgTo
                var recipients = "\((recipientsArray.removeFirst()).username)"
                recipientsArray.forEach({ (recipient) in
                    recipients.append(", \(recipient.username)")
                })
                sender.text = recipients
            } else {
                sender.text = message.msgFrom
            }
            date.text = "\(message.timestamp!) >"
            subject.text = message.msgSubject
            shortMessage.text = message.shortContent
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
