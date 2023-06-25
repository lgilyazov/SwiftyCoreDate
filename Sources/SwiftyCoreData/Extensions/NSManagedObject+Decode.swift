//
//  NSManagedObject+Decode.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import CoreData

extension NSManagedObject {
    
    subscript(primitiveValue forKey: String) -> Any? {
        get {
            defer { didAccessValue(forKey: forKey) }
            willAccessValue(forKey: forKey)
            return primitiveValue(forKey: forKey)
        }
        set(newValue) {
            defer { didChangeValue(forKey: forKey) }
            willChangeValue(forKey: forKey)
            setPrimitiveValue(newValue, forKey: forKey)
        }
    }
    
    func decode<T: ManagedObjectConvertible>() throws -> T {
        try T(from: self)
    }
    
    func update(
        _ item: some ManagedObjectConvertible
    ) throws {
        try item.encodeAttributes(to: self)
    }
    
    func update<T: ManagedObjectConvertible, V: ConvertableValue>(
        _ keyPath: WritableKeyPath<T, V>,
        _ value: V
    ) throws {
        self[primitiveValue: T.attribute(keyPath).name] = value.encode()
    }
    
    func update<T: ManagedObjectConvertible, V: ConvertableValue>(
        _ keyPath: WritableKeyPath<T, V?>,
        _ value: V?
    ) throws {
        self[primitiveValue: T.attribute(keyPath).name] = value?.encode()
    }
}
