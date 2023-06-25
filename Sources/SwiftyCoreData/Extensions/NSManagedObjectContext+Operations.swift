//
//  NSManagedObjectContext+Operations.swift
//
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import CoreData

extension NSManagedObjectContext {
    
    @discardableResult
    func insert(entity name: String) -> NSManagedObject? {
        persistentStoreCoordinator
            .flatMap { $0.managedObjectModel.entitiesByName[name] }
            .flatMap { .init(entity: $0, insertInto: self) }
    }
    
    @discardableResult
    func fetch(
        _ request: Request<some ManagedObjectConvertible>
    ) throws -> [NSManagedObject] {
        let fetchRequest: NSFetchRequest<NSManagedObject> = request.makeFetchRequest()
        return try fetch(fetchRequest)
    }
    
    @_optimize(none)
    @discardableResult
    func fetchOne(
        _ request: Request<some ManagedObjectConvertible>
    ) throws -> NSManagedObject? {
        try fetch(request.limit(1)).first
    }
    
    func delete(
        _ request: Request<some ManagedObjectConvertible>
    ) throws {
        let items = try fetch(request)
        
        for item in items {
            delete(item)
        }
    }
}
