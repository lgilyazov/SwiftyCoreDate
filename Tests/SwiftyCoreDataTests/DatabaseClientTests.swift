//
//  DatabaseClientTests.swift
//  
//
//  Created by Lenar Gilyazov on 29.06.2023.
//

import XCTest
import CoreData
import Combine
@testable import SwiftyCoreData

final class DatabaseClientTests: XCTestCase {
    
    // SUT
    private var sut: DatabaseClient!
    // Dependencies
    private var persistentContainer: NSPersistentContainer!
    private var cancellation: Set<AnyCancellable>!
    
    // MARK: - Life cycle

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellation = []
        persistentContainer = CoreDataContainer(
            name: "SwiftyCoreDataTests",
            bundle: Bundle.module,
            inMemory: true
        )
        persistentContainer.loadPersistentStores(completionHandler: { _, _ in })
        sut = DatabaseClient(persistentContainer: persistentContainer)
    }

    override func tearDownWithError() throws {
        persistentContainer = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Test cases

    @MainActor
    func testAsyncInsert_whenObjectAlreadyExist() async throws {
        // given
        var entity = Entity(id: "test", name: "test")
        try await sut.insert(entity)
        
        // when
        entity.name = "test2"
        try await sut.insert(entity)
        
        // then
        let result = try await sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, entity.name)
    }
    
    @MainActor
    func testAsyncInsert_whenObjectNotExist() async throws {
        // given
        let entity = Entity(id: "test", name: "test")
        
        // when
        try await sut.insert(entity)
        
        // then
        let result = try await sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, entity.name)
    }
    
    @MainActor
    func testAsyncUpdate_whenObjectOptional() async throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try await sut.insert(entity)
        
        // when
        _ = try await sut.update(entity.id, \Entity.name, "test2")
        
        // then
        let result = try await sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "test2")
    }
    
    @MainActor
    func testAsyncUpdate_whenObjectNonOptional() async throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try await sut.insert(entity)
        
        // when
        _ = try await sut.update(entity.id, \Entity.index, 1)
        
        // then
        let result = try await sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.index, 1)
    }
    
    @MainActor
    func testAsyncDelete_whenObjectExist() async throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try await sut.insert(entity)
        
        // when
        _ = try await sut.delete(entity)
        
        // then
        let result = try await sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 0)
    }
    
    @MainActor
    func testAsyncFetch_whenObjectExist() async throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try await sut.insert(entity)
        
        // when
        let result = try await sut.fetch(Entity.all.where(\.id == entity.id))
        
        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "test")
    }
    
    @MainActor
    func testAsyncObserve_whenObjectRecorded() async throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try await sut.insert(entity)
        var results = [[Entity]]()

        // when
        let asyncStream: AsyncStream<[Entity]> = sut.observe(Entity.all)
        try await sut.delete(entity)
        for await result in asyncStream.prefix(2) {
            results.append(result)
        }

        // then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.count, 1)
        XCTAssertEqual(results.first?.first?.id, entity.id)
        XCTAssertEqual(results.last?.isEmpty, true)
    }
    
    func testSyncInsert_whenObjectAlreadyExist() throws {
        // given
        var entity = Entity(id: "test", name: "test")
        try sut.insert(entity)
        
        // when
        entity.name = "test2"
        try sut.insert(entity)
        
        // then
        let result = try  sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, entity.name)
    }
    
    func testSyncInsert_whenObjectNotExist() throws {
        // given
        let entity = Entity(id: "test", name: "test")
        
        // when
        try sut.insert(entity)
        
        // then
        let result = try sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, entity.name)
    }
    
    func testSyncUpdate_whenObjectOptional() throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try sut.insert(entity)
        
        // when
        _ = try sut.update(entity.id, \Entity.name, "test2")
        
        // then
        let result = try sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "test2")
    }
    
    func testSyncUpdate_whenObjectNonOptional() throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try sut.insert(entity)
        
        // when
        _ = try sut.update(entity.id, \Entity.index, 1)
        
        // then
        let result = try sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.index, 1)
    }
    
    func testSyncDelete_whenObjectExist() throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try sut.insert(entity)
        
        // when
        _ = try sut.delete(entity)
        
        // then
        let result = try sut.fetch(Entity.all.where(\.id == entity.id))
        XCTAssertEqual(result.count, 0)
    }
    
    @MainActor
    func testSyncFetch_whenObjectExist() throws {
        // given
        let entity = Entity(id: "test", name: "test")
        try sut.insert(entity)
        
        // when
        let result = try sut.fetch(Entity.all.where(\.id == entity.id))
        
        // then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.name, "test")
    }
}
