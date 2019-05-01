//
//  MemoryTableViewController.swift
//  Memories
//
//  Created by Chris Ward on 4/14/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit
import os.log

class MemoryTableViewController: UITableViewController {
    //MARK: Properties
    var memories =  [Memory]()
    
    @IBOutlet weak var logoutButton: UIButton!
    // Modified viewDidLoad, saveMemories, getDocumentsDirectory, and loadMemories to solve deprecated tutorial issue based on https://stackoverflow.com/questions/53347426/ios-editor-bug-archiveddata-renamed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        let savedMemories = loadMemories()
        
        if savedMemories?.count ?? 0 > 0 {
            memories = savedMemories ?? [Memory]()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell indentifier
        let cellIdentifier = "MemoryTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MemoryTableViewCell else {
            fatalError("The dequeued cell is not an instance of MemoryTableViewCell.")
        }
        
        // Fetches the appropriate memory for the data source layout
        let memory = memories[indexPath.row]
        cell.title.text = memory.title
        cell.photoImageView.image = memory.photo
        cell.date.text = memory.date

        // Configure the cell...

        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            memories.remove(at: indexPath.row)
            saveMemories()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            
        }    
    }


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
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new memory.", log: OSLog.default, type: .debug)
        
        case "ShowDetail":
            
            guard let memoryDetailViewController = segue.destination as? MemoryViewController else {
                fatalError("Unexpected destination: \(segue.destination).")
            }
            
            guard let selectedMemoryCell = sender as? MemoryTableViewCell else {
                fatalError("Unexpected destination: \(segue.destination).")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMemoryCell) else {
                fatalError("The selected cell is not being displayed by the table.")
            }
            
            let selectedMemory = memories[indexPath.row]
            memoryDetailViewController.memory = selectedMemory
            
        case "logoutSegue":
            return
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
 
    //MARK: Actions
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Logout"), style: .cancel, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Logout", comment: "Confirm Logout"), style: .default, handler: { _ in
            NSLog("The \"Logout\" alert occured.")
            self.handleLogout()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleLogout() {
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: "session")
        self.performSegue(withIdentifier: "logoutSegue", sender: self.logoutButton)
        
    }
    
    @IBAction func unwindToMemoryList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? MemoryViewController, let memory = sourceViewController.memory {
            
            let title = memory.title!
            let photo = memory.photo!
            let text = memory.text!
            let date = memory.date!
            
            let url = URL(string: "http://www.kaleidosblog.com/tutorial/login/api/login")
            let session = URLSession.shared
            
            // Encode photo for POST
            let photoData: NSData = photo.pngData()! as NSData
            let photoStringData = photoData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            
            // TO DECODE PHOTO:
            let dataDecoded:NSData = NSData(base64Encoded: photoStringData, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedPhoto:UIImage = UIImage(data: dataDecoded as Data)!
            
            let request = NSMutableURLRequest(url: url!)
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing memory.
                memories[selectedIndexPath.row] = memory
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                // PATCH the memory to the database
                request.httpMethod = "PATCH"
                
                // paramToSend broken up to allow compiler to check code: error "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions" was previously recieved
                let param1 = "title=" + title + "&photo=" + photoStringData
                let param2 = "&text=" + text + "&date=" + date
                let paramToSend = param1 + param2
                
                request.httpBody = paramToSend.data(using: String.Encoding.utf8)
                
                jsonRequest(request: request, session: session)
                
            } else {
                // Add a new memory.
                let newIndexPath = IndexPath(row: memories.count, section: 0)
                memories.append(memory)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
                // POST the memory to the database
                request.httpMethod = "POST"
                
                // paramToSend broken up to allow compiler to check code: error "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions" was previously recieved
                let param1 = "title=" + title + "&photo=" + photoStringData
                let param2 = "&text=" + text + "&date=" + date
                let paramToSend = param1 + param2
                
                request.httpBody = paramToSend.data(using: String.Encoding.utf8)
                
                jsonRequest(request: request, session: session)
            }
            saveMemories()
        }
    }
    
    //MARK: Private Methods
    
    private func saveMemories() {
//        let fullPath = getDocumentsDirectory().appendingPathComponent("memories")
//        
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: memories, requiringSecureCoding: false)
//            try data.write(to: fullPath)
//            os_log("Memories successfully saved.", log: OSLog.default, type: .debug)
//        } catch {
//            os_log("Failed to save memories...", log: OSLog.default, type: .error)
//        }
    }
    
    private func jsonRequest(request: NSMutableURLRequest, session: URLSession) {
        let task = session.dataTask(with: request as URLRequest) { // completionHandler code is implied
            (data, response, error) in
            
            // check for any errors
            guard error == nil else {
                print("error retrieving data from server, error:")
                print(error as Any)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            let json: Any?
            do {
                json = try JSONSerialization.jsonObject(with: responseData, options: [])
            }
            catch {
                print("error trying to convert data to JSON")
                print(String(data: responseData, encoding: String.Encoding.utf8) ?? "[data not convertible to string]")
                return
            }
            
            guard let serverResponse = json as? NSDictionary else {
                print("error trying to convert data to NSDictionary")
                return
            }
            
            
        }
        task.resume()
        
        
    }
    
    private func updateMemoryID(serverResponse: NSDictionary, memory: Memory) -> Memory {
        guard memory.id = serverResponse["id"]
        return memory
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func loadMemories() -> [Memory]? {
        let fullPath = getDocumentsDirectory().appendingPathComponent("memories")
        if let nsData = NSData(contentsOf: fullPath) {
            do {
                
                let data = Data(referencing:nsData)
                
                if let loadedMemories = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Array<Memory> {
                    return loadedMemories
                }
            } catch {
                print("Couldn't read file.")
                return nil
            }
        }
        return nil
    }
}
