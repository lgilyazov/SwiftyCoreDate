//
//  IDatabaseClient.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import Foundation
import Combine

public protocol IDatabaseClient: AnyObject {
    
    // MARK: - Sync
    
    func insert<T: ManagedObjectConvertible>(_ item: T) throws
    
    func update<T: ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V>,
        _ value: V
    ) throws -> Bool
    
    func update<T: ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V?>,
        _ value: V?
    ) throws -> Bool
    
    func delete<T: ManagedObjectConvertible>(_ item: T) throws
    func fetch<T: ManagedObjectConvertible>(_ request: Request<T>) throws -> [T]
    func observe<T: ManagedObjectConvertible>(_ request: Request<T>) -> AnyPublisher<[T], Error>
    
    // MARK: - Async
    
    func insert<T: ManagedObjectConvertible>(_ item: T) async throws
    
    @discardableResult
    func update<T: ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V>,
        _ value: V
    ) async throws -> Bool
    
    @discardableResult
    func update<T: ManagedObjectConvertible, V: ConvertableValue>(
        _ id: T.ID,
        _ keyPath: WritableKeyPath<T, V?>,
        _ value: V?
    ) async throws -> Bool
    
    func delete<T: ManagedObjectConvertible>(_ item: T) async throws
    func fetch<T: ManagedObjectConvertible>(_ request: Request<T>) async throws -> [T]
    func observe<T: ManagedObjectConvertible>(_ request: Request<T>) -> AsyncStream<[T]>
}
