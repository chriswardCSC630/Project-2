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
        
        loadMemories() // to populate the memories array
        
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
            let memory = memories.remove(at: indexPath.row)
            deleteMemory(memory: memory)
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
        preferences.removeObject(forKey: "username")
        self.performSegue(withIdentifier: "logoutSegue", sender: self.logoutButton)
        
    }
    
    @IBAction func unwindToMemoryList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? MemoryViewController, let memory = sourceViewController.memory {
            
            let title = memory.title!
            let photo = memory.photo!
            let text = memory.text!
            let date = memory.date!
            let id = memory.id!
            
            // Encode photo for POST
            let photoData: NSData = photo.pngData()! as NSData
            let photoStringData = photoData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // PATCH the memory to the database
                
                // paramToSend broken up to allow compiler to check code: error "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions" was previously recieved
                let param1 = "title=" + title + "&photo=" + photoStringData
                let param2 = "&text=" + text + "&date=" + date + "&id=" + id
                let paramToSend = param1 + param2
                makeURLRequest(urlString: "https://fullstack-project-2.herokuapp.com/memories/", method: "PATCH", paramToSend: paramToSend, memory: memory)
                // Update an existing memory.
                memories[selectedIndexPath.row] = memory // test this later, we may need to actually save the new memory if it's not just a reference
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            } else {
                // POST the memory to the database
                
                // paramToSend broken up to allow compiler to check code: error "The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions" was previously recieved
                let param1 = "title=" + title + "&photo=" + photoStringData
                let param2 = "&text=" + text + "&date=" + date
                let paramToSend = param1 + param2
                
                makeURLRequest(urlString: "https://fullstack-project-2.herokuapp.com/memories/", method: "POST", paramToSend: paramToSend, memory: memory)
                
                // Add a new memory.
                let newIndexPath = IndexPath(row: memories.count, section: 0)
                memories.append(memory)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
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
    
    private func updateMemoryID(serverResponse: NSDictionary, memory: Memory){
        guard let id = serverResponse["id"] as? String else {
            print("No id")
            return
        }
        memory.id = id
    }
    
    
    private func loadMemories() {
    
        // GET the memories from the database
        makeURLRequest(urlString: "https://fullstack-project-2.herokuapp.com/memories/", method: "GET")
            
    }
    
    func populateMemories(data:NSDictionary) {
        
        for id in data.allKeys {
            guard let currentMemory = data[id] as? NSDictionary else {
                print("invalid response format: content")
                return
            }
            // the data will be arranged by keys
            
            guard let title = currentMemory["title"] as? String else {
                print("invalid response format: title")
                return
            }
            
            guard let photoString = currentMemory["image"] as? String else {
                print("invalid response format: photoString")
                return
            }
            guard let text = currentMemory["text"] as? String else {
                print("invalid response format: text")
                return
            }
            
            guard let id = id as? String else {
                print("invalid response format: id")
                return
            }
            
            // TO DECODE PHOTO:
            let dataDecoded:NSData = NSData(base64Encoded: photoString, options: NSData.Base64DecodingOptions(rawValue: 0))!
            let decodedPhoto:UIImage = UIImage(data: dataDecoded as Data)!
            
            let memory = Memory(title: title, photo: decodedPhoto, text: text)
            memory!.id = id
            memories.append(memory!)
        }
        
        tableView.reloadData()
        
    }
    
    func deleteMemory(memory: Memory) {
  
        let paramToSend = "id=" + memory.id!
        
        // DELETE the memory from the database
        makeURLRequest(urlString: "https://fullstack-project-2.herokuapp.com/memories/", method: "DELETE", paramToSend: paramToSend, memory: memory)
    
    }
    
    func makeURLRequest(urlString: String, method: String, paramToSend: String? = "", memory: Memory? = nil) {
        let url = URL(string: urlString)
        let session = URLSession.shared
        
        
        let request = NSMutableURLRequest(url: url!)
        
        // PATCH the memory to the database
        request.httpMethod = method
        
        if (method == "POST" || method == "PATCH" || method == "DELETE") {
            let params: String = paramToSend ?? ""
            request.httpBody = params.data(using: String.Encoding.utf8)
        }
        
        
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
            
            if (method == "GET") {
                self.populateMemories(data: serverResponse)
            }
            else if (method == "POST") {
                if memory == nil {
                    print("Memory passed in incompatible format -- POST")
                    return
                }
                self.updateMemoryID(serverResponse: serverResponse, memory: memory!)
            }
            else if (method == "PATCH") {
                return
            }
            else if (method == "DELETE") {
                return
            }
        }
        task.resume()
    }
}
