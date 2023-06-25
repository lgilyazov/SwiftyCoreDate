//
//  ManagedObjectConvertible.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import Foundation

public protocol ManagedObjectConvertible {
    associatedtype ID: ConvertableValue where ID: Equatable
    static var entityName: String { get }
    static var idKeyPath: KeyPath<Self, ID> { get }
    static var attributes: Set<Attribute<Self>> { get }
    
    init()
}
