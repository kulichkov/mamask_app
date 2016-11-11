//
//  BoxesTableViewController.swift
//  mamask_app
//
//  Created by Mikhail Kulichkov on 10/11/16.
//  Copyright © 2016 Mikhail Kulichkov. All rights reserved.
//

import UIKit

struct Box {
    var unreadCount: Int = 0
    var boxID: String = ""
    var boxType: String = ""
    var boxName: String = ""
    var msgCount: Int = 0
}

fileprivate struct Constants {
    static let boxCellReuseIdentifier = "Box Cell"
    static let showBoxIdentifier = "Show Box"
}

class BoxesTableViewController: UITableViewController {

    var tapatalk: TapatalkAPI? {
        didSet {
            getBoxInfo()
        }
    }
    private var messageRoomCount: Int = 0
    private var boxes = [Box]()


    private func getBoxInfo() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak weakSelf = self] in
            print("Starting tapatalk.get_box_info()...")
            weakSelf?.tapatalk?.get_box_info() { getBoxInfoResult in
                DispatchQueue.main.async {
                    print("Starting handler in get_box_info...")
                    if let messageRoomCount = getBoxInfoResult["message_room_count"] as? Int {
                        weakSelf?.messageRoomCount = messageRoomCount
                    }
                    if let boxes = getBoxInfoResult["list"] as? [[String: Any?]] {
                        weakSelf?.boxes = [Box]()
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
                            weakSelf?.boxes.append(newBox)
                            weakSelf?.navigationItem.title = "Ящики"
                            weakSelf?.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBoxInfo()
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueIdentifier = segue.identifier {
            if segueIdentifier == Constants.showBoxIdentifier {
                if let btvc = segue.destination.contentViewController as? BoxTableViewController, let selectedBox = sender as? UITableViewCell {
                    let indexOfSelected = (tableView.indexPath(for: selectedBox)?.row)!
                    btvc.tapatalk = tapatalk
                    btvc.boxName = boxes[indexOfSelected].boxName
                    btvc.boxID = boxes[indexOfSelected].boxID
                }
            }
        }
    }

}
