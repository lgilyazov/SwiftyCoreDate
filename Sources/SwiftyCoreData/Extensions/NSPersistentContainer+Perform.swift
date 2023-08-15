//
//  NSPersistentContainer+Perform.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import CoreData

extension NSPersistentContainer {
    
    enum Error: Swift.Error {
        case noResult
    }
    
    @discardableResult
    func perform<T>(
        action: @Sendable @escaping (NSManagedObjectContext) throws -> T
    ) throws -> T {
        do {
            let context = newBackgroundContext()
            
            if #available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *) {
                return try context.performAndWait {
                    try context.execute(action)
                }
            }
            
            var result: Result<T, Swift.Error>?
            
            context.performAndWait {
                result = Result(catching: {
                    try context.execute(action)
                })
            }
            
            switch result {
            case let .success(value):
                return value
            case let .failure(error):
                throw error
            case .none:
                throw Self.Error.noResult
            }
        } catch {
            throw error
        }
    }
    
    func schedule<T>(
        _ action: @Sendable @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try Task.checkCancellation()
        
        let context = newBackgroundContext()
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) {
            return try await context.perform(schedule: .immediate) {
                try context.execute(action)
            }
        } else {
            return try await withUnsafeThrowingContinuation { continuation in
                continuation.resume(
                    with: .init { try context.execute(action) }
                )
            }
        }
    }
}
