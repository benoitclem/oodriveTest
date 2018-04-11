//
//  OutlineTableViewCell.swift
//  Testing
//
//  Created by Clément on 10/04/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Cocoa

class OutlineTableViewCell: NSTableCellView {

    @IBOutlet weak public var Icon: NSImageView!
    @IBOutlet weak public var Title: NSTextField!
    @IBOutlet weak public var MinusButton: NSButton!
    @IBOutlet weak public var PlusButton: NSButton!
    
    public var isDir: Bool = false
    
    override func awakeFromNib() {
        NSLog("nib \(self.frame.debugDescription)")
        
        self.addTrackingArea(NSTrackingArea(rect: self.frame, options: [.activeAlways, .mouseEnteredAndExited] , owner: self, userInfo: nil))
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func mouseEntered(with event: NSEvent) {
        if self.isDir {
            self.MinusButton.isHidden = false
            self.PlusButton.isHidden = false
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        if self.isDir {
            self.MinusButton.isHidden = true
            self.PlusButton.isHidden = true
        }
    }
    
}
