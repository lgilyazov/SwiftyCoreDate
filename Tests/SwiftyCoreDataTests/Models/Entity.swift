//
//  Entity.swift
//  
//
//  Created by Lenar Gilyazov on 29.06.2023.
//

import Foundation
import SwiftyCoreData

struct Entity {
    
    var id: String = ""
    var index: Int64 = 0
    var name: String?
}

extension Entity: ManagedObjectConvertible {
    
    static var idKeyPath: KeyPath<Entity, String> {
        \.id
    }
    
    static var entityName: String {
        "CDEntity"
    }
    
    static var attributes: Set<Attribute<Entity>> = [
        .init(\.id, "id"),
        .init(\.index, "index"),
        .init(\.name, "name")
    ]
}
