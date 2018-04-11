//
//  Node.swift
//  Testing
//
//  Created by Clément on 10/04/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Cocoa
import SwiftyJSON
import ObjectiveC

enum contentType {
    case text, pdf, jpg
}

class Node: NSObject {
    public var id: String!
    public var name: String!
    public var isDir: Bool?
    public var parentId: String?
    public var contentType: contentType?
    public var size: Int?
    public var modificationDate: Date?
    public var children: [Node] = []
    
    public var parent: Node?
    
    init(fromDictionary dictionary: Dictionary<String, Any>) {
        self.id = dictionary["id"] as! String
        self.name = dictionary["name"] as! String
        self.isDir = dictionary["isDir"] as! Bool
    }
    
    init(fromJson json:JSON) {
        if let id = json["id"].string {
            // it's reasonable to think that the node is populated
            self.id = id
            if let name = json["name"].string {
                self.name = name
            }
            if let isDir = json["isDir"].bool {
                self.isDir = isDir
            }
            if let parentId = json["parentId"].string {
                self.parentId = parentId
            }
            if let contentType = json["contentType"].string {
                if contentType == "image/jpg" {
                    self.contentType = .jpg
                }
                // TODO: implementation here the otgher file formats
            }
            if let size = json["size"].int {
                self.size = size
            }
        }
    }
    
    func addChild(_ node: Node) {
        // Do the append only if the child is not appended yet
        if !self.children.contains(where: { $0.id == node.id}) {
            node.parent = self
            self.children.append(node)
        }
    }
    
    func deleteChild(_ node: Node) -> Bool {
        if let index = self.children.index(where: { $0.id == node.id}) {
            self.children.remove(at: index)
            return true
        }
        return false
    }
}
