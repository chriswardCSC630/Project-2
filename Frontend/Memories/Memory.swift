//
//  Memory.swift
//  Memories
//
//  Created by Chris Ward on 4/13/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit
import os.log

class Memory: NSObject, NSCoding {
    
    //MARK: Properties
    
    var title: String?
    var photo: UIImage?
    var text: String?
    var taggedUsers: String?
    var date: String?
    
    //MARK: Archiving Points
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("memories")

    
    //MARK: Types
    
    struct PropertyKey{
        static let title = "title"
        static let photo = "photo"
        static let text = "text"
        static let taggedUsers = "taggedUsers"
        static let date = "date"
    }
    
    //MARK: Initializers
    init?(title: String, photo: UIImage?, text: String, taggedUsers: String){
        // Name must not be empty
        guard !title.isEmpty else {
            return nil
        }
        
        // Initialize Stored Properties
        self.title = title
        self.photo = photo
        self.text = text
        self.taggedUsers = taggedUsers
        
        // How should we get the date? from a date picker or something else?
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(text, forKey: PropertyKey.text)
        aCoder.encode(taggedUsers, forKey: PropertyKey.taggedUsers)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The title is required. If we cannot decode a title string, the initializer should fail.
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String
            else {
                os_log("Unable to decode the title for a Memory object.", log: OSLog.default,
                       type: .debug)
                return nil
        }
        
        // Because photo is an optional property of Memory, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        // The text is required. If we cannot decode a text string, the initializer should fail.
        guard let text = aDecoder.decodeObject(forKey: PropertyKey.text) as? String
            else {
                os_log("Unable to decode the text for a Memory object.", log: OSLog.default,
                       type: .debug)
                return nil
        }
        
        // Because taggedUsers is an optional property of Memory, just use conditional cast.
        let taggedUsers = aDecoder.decodeObject(forKey: PropertyKey.taggedUsers) as? String
        
        // Must call designated initializer.
        self.init(title: title, photo: photo, text: text, taggedUsers: taggedUsers)
    }
}

