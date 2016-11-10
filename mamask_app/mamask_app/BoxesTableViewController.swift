//
//  BoxesTableViewController.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 10/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import UIKit

/*
 ["message_room_count": 360, "list": [["unread_count": 0, "box_id": inbox, "box_type": INBOX, "box_name": "Входящие", "msg_count": 0], ["unread_count": 0, "box_id": sent, "box_type": SENT, "box_name": "Отправленные", "msg_count": 5]]]
 */
struct Box {
    var unreadCount: Int = 0
    var boxID: String = ""
    var boxType: String = ""
    var boxName: String = ""
    var msgCount: Int = 0
}

fileprivate struct Constants {
    static let boxCellReuseIdentifier = "Box Cell"
}

class BoxesTableViewController: UITableViewController {

    var messageRoomCount: Int = 0
    var boxes = [Box]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("messageRoomCount = \(messageRoomCount)")
        print("boxes = \(boxes)")
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
        return boxes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.boxCellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = boxes[indexPath.row].boxName
        cell.detailTextLabel?.text = "сообщений: \(boxes[indexPath.row].msgCount), непрочитанных: \(boxes[indexPath.row].unreadCount)"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
