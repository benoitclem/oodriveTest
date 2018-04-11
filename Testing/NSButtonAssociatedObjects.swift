//
//  NSButtonAssociatedObjects.swift
//  Testing
//
//  Created by Clément on 11/04/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Cocoa
import ObjectiveC

// Declare a global var to produce a unique address as the assoc object handle
private var AssociatedObjectHandle: UInt8 = 0

extension NSButton {
    var associatedNode:Node {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! Node
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
