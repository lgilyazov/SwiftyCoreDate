//
//  Attribute.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import Foundation
import CoreData
import OrderedCollections

public final class Attribute<PlainObject: ManagedObjectConvertible>: Hashable {
    
    // Properties
    let name: String
    let encode: (PlainObject, NSManagedObject) throws -> Void
    let decode: (inout PlainObject, NSManagedObject) throws -> Void
    let keyPath: PartialKeyPath<PlainObject>
    private(set) var isRelation = false
    
    // MARK: - Primitive Values
    
    public init<Value: ConvertableValue>(
        _ keyPath: WritableKeyPath<PlainObject, Value>,
        _ name: String
    ) {
        self.name = name
        self.encode = { plainObject, managedObject in
            managedObject[primitiveValue: name] = plainObject[keyPath: keyPath].encode()
        }
        self.decode = { plainObject, managedObject in
            do {
                plainObject[keyPath: keyPath] = try Value.decode(managedObject[primitiveValue: name])
            } catch {
                throw AttributeError.failedToDecode(for: name, model: PlainObject.entityName)
            }
        }
        self.keyPath = keyPath
    }
    
    // MARK: - Optional Primitive Attribute
    
    public init<Value: ConvertableValue>(
        _ keyPath: WritableKeyPath<PlainObject, Value?>,
        _ name: String
    ) {
        self.name = name
        self.encode = { plainObject, managedObject in
            managedObject[primitiveValue: name] = plainObject[keyPath: keyPath]?.encode()
        }
        self.decode = { plainObject, managedObject in
            do {
                plainObject[keyPath: keyPath] = try Value?.decode(managedObject[primitiveValue: name])
            } catch {
                throw AttributeError.failedToDecode(for: name, model: PlainObject.entityName)
            }
        }
        self.keyPath = keyPath
    }
    
    // MARK: - To One
    
    public init<Relation: ManagedObjectConvertible>(
        _ keyPath: WritableKeyPath<PlainObject, Relation>,
        _ name: String
    ) {
        self.name = name
        self.encode = { plainObject, managedObject in
            try plainObject[keyPath: keyPath].encodeAttributes(to: managedObject)
        }
        self.decode = { plainObject, managedObject in
            guard let object = managedObject.value(forKey: name) as? NSManagedObject else {
                throw AttributeError.failedToDecode(for: name, model: PlainObject.entityName)
            }
            
            plainObject[keyPath: keyPath] = try Relation(from: object)
        }
        self.keyPath = keyPath
        self.isRelation = true
    }
    
    // MARK: - To Many
    
    public init<Relation: ManagedObjectConvertible>(
        _ keyPath: WritableKeyPath<PlainObject, Set<Relation>>,
        _ name: String
    ) {
        self.name = name
        self.encode = { plainObject, managedObject in
            let managedObjects = managedObject.mutableSetValue(forKey: name)
            let objects = plainObject[keyPath: keyPath]
            
            // Adding and updating existing elements
            for object in objects {
                var managed = try managedObjects.compactMap { $0 as? NSManagedObject }
                    .first { try Relation(from: $0)[keyPath: Relation.idKeyPath] == object[keyPath: Relation.idKeyPath] }
                
                if managed == nil {
                    managed = try managedObject.managedObjectContext?
                        .fetchOne(Relation.all.where(Relation.idKeyPath == object[keyPath: Relation.idKeyPath]))
                }
                
                if managed == nil {
                    managed = managedObject.managedObjectContext?.insert(entity: Relation.entityName)
                }
                
                guard let managed else {
                    throw AttributeError.failedToEncodeRelation(for: name, model: PlainObject.entityName)
                }
                
                managedObjects.add(managed)
                try managed.update(object)
            }
            
            // Remove elements not in array
            let copiedManagedObjects = (managedObjects.copy() as? NSSet)?
                .compactMap { $0 as? NSManagedObject } ?? .init()
            
            for managed in copiedManagedObjects {
                guard let wrapped = try? Relation(from: managed) else {
                    continue
                }
                
                if !objects
                    .contains(where: { wrapped[keyPath: Relation.idKeyPath] == $0[keyPath: Relation.idKeyPath] }) {
                    managedObjects.remove(managed)
                }
            }
        }
        self.decode = { plainObject, managedObject in
            guard let objects = managedObject.value(forKey: name) as? NSSet as? Set<NSManagedObject> else {
                throw AttributeError.failedToDecode(for: name, model: PlainObject.entityName)
            }
            
            plainObject[keyPath: keyPath] = try Set(objects.compactMap { try Relation(from: $0) })
        }
        self.keyPath = keyPath
        self.isRelation = true
    }
    
    // MARK: To Many Ordered
    
    public init<Relation: ManagedObjectConvertible>(
        _ keyPath: WritableKeyPath<PlainObject, OrderedSet<Relation>>,
        _ name: String
    ) {
        self.name = name
        self.encode = { plainObject, managedObject in
            let managedObjects = managedObject.mutableOrderedSetValue(forKey: name)
            let objects = plainObject[keyPath: keyPath]
            
            // Adding and updating existing elements
            for (index, object) in objects.enumerated() {
                var managed = try managedObjects.compactMap { $0 as? NSManagedObject }
                    .first { try Relation(from: $0)[keyPath: Relation.idKeyPath] == object[keyPath: Relation.idKeyPath] }
                
                if managed == nil {
                    managed = try managedObject.managedObjectContext?
                        .fetchOne(Relation.all.where(Relation.idKeyPath == object[keyPath: Relation.idKeyPath]))
                }
                
                if managed == nil {
                    managed = managedObject.managedObjectContext?.insert(entity: Relation.entityName)
                }
                
                guard let managed else {
                    throw AttributeError.failedToEncodeRelation(for: name, model: PlainObject.entityName)
                }
                
                if managedObjects.contains(managed) {
                    managedObjects.remove(managed)
                }
                
                managedObjects.insert(managed, at: index)
                
                try managed.update(object)
            }
            
            // Remove elements not in array
            let copiedManagedObjects = (managedObjects.copy() as? NSOrderedSet)?
                .compactMap { $0 as? NSManagedObject } ?? .init()
            
            for managed in copiedManagedObjects {
                guard let wrapped = try? Relation(from: managed) else {
                    continue
                }
                
                if !objects
                    .contains(where: { wrapped[keyPath: Relation.idKeyPath] == $0[keyPath: Relation.idKeyPath] }) {
                    managedObjects.remove(managed)
                }
            }
        }
        self.decode = { plainObject, managedObject in
            guard let objects = managedObject.value(forKey: name) as? NSOrderedSet else {
                throw AttributeError.failedToDecode(for: name, model: PlainObject.entityName)
            }
            
            plainObject[keyPath: keyPath] = try OrderedSet(
                objects.compactMap { $0 as? NSManagedObject }
                    .compactMap { try Relation(from: $0) }
            )
        }
        self.keyPath = keyPath
        self.isRelation = true
    }
    
    // MARK: - Hashsable
    
    public static func == (lhs: Attribute<PlainObject>, rhs: Attribute<PlainObject>) -> Bool {
        lhs.name == rhs.name
    }
    
    // MARK: - Equatable
    
    public func hash(into hasher: inout Hasher) {
        name.hash(into: &hasher)
    }
}
