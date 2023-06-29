//
//  DatabaseClient.swift
//
//
//  Created by Lenar Gilyazov on 25.06.2023.
//

import Foundation
import CoreData
import Combine

final class DatabaseClient: IDatabaseClient {
    
    // Dependencies
    private let persistentContainer: NSPersistentContainer
    
    // MARK: - Initialization
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    // MARK: - IDatabaseClient
    
    // MARK: - Async
    
    func insert<T : ManagedObjectConvertible>(
        _ item: T
    ) async throws {
        try await persistentContainer.schedule { [self] context in
            try insert(item, in: context)
        }
    }
    
    func update<T : ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V?>,
        _ value: V?
    ) async throws -> Bool {
        try await persistentContainer.schedule { [self] context in
            try update(id, keyPath, value, in: context)
        }
    }
    
    func update<T : ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V>,
        _ value: V
    ) async throws -> Bool {
        try await persistentContainer.schedule { [self] context in
            try update(id, keyPath, value, in: context)
        }
    }
    
    func delete<T : ManagedObjectConvertible>(
        _ item: T
    ) async throws {
        try await persistentContainer.schedule { [self] context in
            try delete(item, in: context)
        }
    }
    
    func fetch<T : ManagedObjectConvertible>(
        _ request: Request<T>
    ) async throws -> [T] {
        try await persistentContainer.schedule { [self] context in
            try fetch(request, in: context)
        }
    }
    
    func observe<T : ManagedObjectConvertible>(
        _ request: Request<T>
    ) -> AsyncStream<[T]> {
        .init { continuation in
            Task.detached { [weak self] in
                guard let self else { return }
                let values = try? await self.fetch(request)
                continuation.yield(values ?? [])
                
                let observe = NotificationCenter.default.observeNotifications(
                    from: NSManagedObjectContext.didSaveObjectsNotification
                )
                
                for await _ in observe {
                    let values = try? await self.fetch(request)
                    continuation.yield(values ?? [])
                }
            }
        }
    }
    
    // MARK: - Sync
    
    func insert<T : ManagedObjectConvertible>(_ item: T) throws {
        let context = persistentContainer.viewContext
        try insert(item, in: context)
    }
    
    func update<T : ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V?>,
        _ value: V?
    ) throws -> Bool {
        let context = persistentContainer.viewContext
        return try update(id, keyPath, value, in: context)
    }
    
    func update<T : ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V>,
        _ value: V
    ) throws -> Bool {
        let context = persistentContainer.viewContext
        return try update(id, keyPath, value, in: context)
    }
    
    func delete<T : ManagedObjectConvertible>(
        _ item: T
    ) throws {
        let context = persistentContainer.viewContext
        try delete(item, in: context)
    }
    
    func fetch<T : ManagedObjectConvertible>(
        _ request: Request<T>
    ) throws -> [T] {
        let context = persistentContainer.viewContext
        return try fetch(request, in: context)
    }
    
    // MARK: - Private
    
    // MARK: - Commit
    
    private func insert<T : ManagedObjectConvertible>(_ item: T, in context: NSManagedObjectContext) throws {
        let object: NSManagedObject?
        
        if let objectFound = try context.fetchOne(T.all.where(T.idKeyPath == item[keyPath: T.idKeyPath])) {
            object = objectFound
        } else {
            object = context.insert(entity: T.entityName)
        }
        
        try object?.update(item)
    }
    
    private func update<T : ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V?>,
        _ value: V?,
        in context: NSManagedObjectContext
    ) throws -> Bool {
        if let managed = try context.fetchOne(T.all.where(T.idKeyPath == id)) {
            try managed.update(keyPath, value)
            return true
        } else {
            return false
        }
    }
    
    private func update<T : ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V>,
        _ value: V,
        in context: NSManagedObjectContext
    ) throws -> Bool {
        if let managed = try context.fetchOne(T.all.where(T.idKeyPath == id)) {
            try managed.update(keyPath, value)
            return true
        } else {
            return false
        }
    }
    
    private func delete<T : ManagedObjectConvertible>(
        _ item: T,
        in context: NSManagedObjectContext
    ) throws {
        try context.delete(T.all.where(T.idKeyPath == item[keyPath: T.idKeyPath]))
    }
    
    private func fetch<T : ManagedObjectConvertible>(
        _ request: Request<T>,
        in context: NSManagedObjectContext
    ) throws -> [T] {
        try context.fetch(request).map { try $0.decode() }
    }
}
