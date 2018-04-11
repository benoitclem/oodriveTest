//
//  BrowsingViewController.swift
//  Testing
//
//  Created by Clément on 09/04/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Cocoa
import Foundation

class BrowsingViewController: NSViewController {
    
    let netApi = oodNetApi.sharedInstance
    
    var root : Node?
    
    @IBOutlet weak var FileOutlineView: NSOutlineView!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.titleVisibility = .hidden
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.styleMask.insert(.fullSizeContentView)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        NSLog("salut")
        
        /*
        // Some dummy data for testing purpose
        let rootNodeData: [String: Any] = ["id": "123", "name": "root", "isDir": true]
        let Node1Data: [String: Any] = ["id": "234", "name": "dir1", "isDir": true]
        let Node2Data: [String: Any] = ["id": "345", "name": "file1", "isDir": false]
        let Node3Data: [String: Any] = ["id": "456", "name": "file2", "isDir": false]
        
        root = Node(fromDictionary: rootNodeData)
        let n1 = Node(fromDictionary: Node1Data)
        let n2 = Node(fromDictionary: Node2Data)
        let n3 = Node(fromDictionary: Node3Data)
        root?.addChild(n1)
        root?.addChild(n2)
        n1.addChild(n3)
        */
        
        self.FileOutlineView.dataSource = self
        self.FileOutlineView.delegate = self
        self.FileOutlineView.target = self
        self.FileOutlineView.doubleAction = #selector(BrowsingViewController.doubleActionEvent)
        
        self.FileOutlineView.register(forDraggedTypes: [NSURLPboardType])
        self.FileOutlineView.draggingDestinationFeedbackStyle = .regular
        self.FileOutlineView.setDraggingSourceOperationMask(.copy, forLocal: false)
        //self.FileOutlineView.draggingSession(<#T##session: NSDraggingSession##NSDraggingSession#>, sourceOperationMaskFor: <#T##NSDraggingContext#>)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func trigReload() {
        if let rootNodeId = self.root?.id {
            netApi.getNodes(with: rootNodeId) { nodes, error in
                if error == nil {
                    print("Got Nodes \(nodes)")
                    if let checkedNodes = nodes {
                        for node in checkedNodes {
                            self.root?.addChild(node)
                        }
                    }
                    self.FileOutlineView.reloadData()
                } else {
                    print("\(error)")
                }
            }
        }
        
    }
    
    func clickedPlusButton(button:NSButton) {
        let workingNode = button.associatedNode
        NSLog("Clicked + \(workingNode.id)")
        if let nodeId = button.associatedNode.id {
            self.netApi.createFolder(into: nodeId, "new folder") { node, error in
                if error == nil {
                    print("Node Created")
                    if let validNode = node {
                        workingNode.addChild(validNode)
                    }
                    self.FileOutlineView.reloadItem(workingNode, reloadChildren: true)
                } else {
                    print("\(error)")
                }
            }
        }
    }
    
    func clickedMinusButton(button:NSButton) {
        let workingNode = button.associatedNode
        NSLog("Clicked - \(button.associatedNode.id)")
        if let nodeId = button.associatedNode.id {
            self.netApi.deleteNode(with: nodeId) { error in
                if error == nil {
                    workingNode.parent?.deleteChild(workingNode)
                    self.FileOutlineView.reloadItem(workingNode.parent, reloadChildren: true)
                }
            }
        }
    }

    func doubleActionEvent(sender:NSOutlineView) {
        NSLog("Double Click occured \(sender.clickedRow)")
        NSLog("\(sender.item(atRow: sender.selectedRow))")
        if let node = sender.item(atRow: sender.selectedRow) as? Node{
            self.netApi.downloadFile(with: node.id) { data, error in
                if error == nil {
                    // Create temps file
                    let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(node.name)
                    do {
                        // Write it
                        try data?.write(to: tempUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                    // Open it
                    NSWorkspace.shared().open(tempUrl)
                } else {
                    NSLog("\(error)")
                }
            }
        }
    }
    
}


extension BrowsingViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let node = item as? Node {
            return node.children.count
        }
        if self.root != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let node = item as? Node {
            return node.children[index]
        }
        if self.root != nil {
            return self.root!
        } else {
            return self.root!
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let currentNode = item as? Node {
            return currentNode.isDir!
        }
        return false
    }
    
    
}

extension BrowsingViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: OutlineTableViewCell?
        if let node = item as? Node {
            if tableColumn?.identifier == "name" {
                view = outlineView.make(withIdentifier: "NodeCell", owner: self) as? OutlineTableViewCell
                if let textField = view?.Title {
                    textField.stringValue = node.name!
                    textField.sizeToFit()
                }
                view?.isDir = node.isDir!
                view?.PlusButton.isHidden = true
                view?.PlusButton.target = self
                view?.PlusButton.action = #selector(BrowsingViewController.clickedPlusButton)
                view?.PlusButton.associatedNode = node
                view?.MinusButton.isHidden = true
                view?.MinusButton.target = self
                view?.MinusButton.action = #selector(BrowsingViewController.clickedMinusButton)
                view?.MinusButton.associatedNode = node
                // Resolve the childs
                if node.isDir! {
                    netApi.getNodes(with: node.id!) { childNodes, error in
                        if error == nil {
                            print("Got ChildNodes \(childNodes)")
                            if childNodes != nil {
                                for childnode in childNodes! {
                                    node.addChild(childnode)
                                }
                            }
                        } else {
                            print("\(error)")
                        }
                    }
                }
            }
        }
        return view
    }
    
    // Start drag and drop stuff
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        if let workingNode = items[0] as? Node {
            NSLog("\(workingNode.name)")
            // For the Testing we provide only the capability of downloading individual filaes
            if !workingNode.isDir! {
                pasteboard.declareTypes([NSFilesPromisePboardType], owner: self)
                pasteboard.setPropertyList([workingNode.id], forType: NSFilesPromisePboardType)
                return true
            }
        }
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedItems items: [Any]) -> [String] {
        NSLog("\(dropDestination)")
        if let workingNode = items[0] as? Node {
            NSLog("\(workingNode.name)")
            self.netApi.downloadFile(with: workingNode.id) { data, error in
                if error == nil {
                    // Create temps file
                    let dropUrl = dropDestination.appendingPathComponent(workingNode.name)
                    do {
                        // Write it
                        try data?.write(to: dropUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                    // Open it
                    //NSWorkspace.shared().open(tempUrl)
                } else {
                    NSLog("\(error)")
                }
            }
        }
        return []
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        if (nil == info.draggingSource()) {
            return .copy
        }
        return NSDragOperation(rawValue: 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        let pb = info.draggingPasteboard()
        if let types = pb.types {
            let b = types.contains(NSURLPboardType)
            if b {
                if let workingNode = item as? Node {
                    let url = NSURL(from: pb)
                    let fileData = NSData(contentsOf: url as! URL)
                    NSLog("\(workingNode.id) <- \(url)")
                    if let fileName = url?.lastPathComponent {
                        self.netApi.createFile(into: workingNode.id, fileName, fileData! as Data, completion: { node, error in
                            if error == nil {
                                print("Node Created")
                                if let validNode = node {
                                    workingNode.addChild(validNode)
                                }
                                self.FileOutlineView.reloadItem(workingNode, reloadChildren: true)
                            } else {
                                NSLog("Could not upload file")
                            }
                        }, andProgress: { progress in
                            NSLog("progres: \(progress)")
                        })
                    }
                }
            }
        }
        return true
    }

}

extension BrowsingViewController: NSDraggingDestination {

}

