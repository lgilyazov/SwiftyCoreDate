//
//  ManagedObjectConvertible+Attributes.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import CoreData

extension ManagedObjectConvertible {
    
    static func attribute(_ keyPath: KeyPath<Self, some Any>) -> Attribute<Self> {
        attributes.first { $0.keyPath == keyPath }.unsafelyUnwrapped
    }
    
    @discardableResult
    func encodeAttributes(to managedObject: NSManagedObject) throws -> NSManagedObject {
        try Self.attributes.forEach { attribute in
            try attribute.encode(self, managedObject)
        }
        return managedObject
    }
    
    init(from managedObject: NSManagedObject) throws {
        self.init()
        try Self.attributes.forEach { attribute in
            try attribute.decode(&self, managedObject)
        }
    }
}
