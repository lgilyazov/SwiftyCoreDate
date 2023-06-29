//
//  CoreDataContainer.swift
//
//
//  Created by Lenar Gilyazov on 29.06.2023.
//

import Foundation
import CoreData

final class CoreDataContainer: NSPersistentContainer {
    
    init(name: String, bundle: Bundle = .main, inMemory: Bool = false) {
        guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            fatalError("Failed to create mom")
        }
        super.init(name: name, managedObjectModel: mom)
        configureDefaults(inMemory)
    }
    
    private func configureDefaults(_ inMemory: Bool = false) {
        if let storeDescription = persistentStoreDescriptions.first {
            storeDescription.shouldAddStoreAsynchronously = true
            if inMemory {
                storeDescription.url = URL(fileURLWithPath: "/dev/null")
                storeDescription.shouldAddStoreAsynchronously = false
            }
        }
    }
}
