//
//  NSManagedObjectContext+Execute.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import CoreData

extension NSManagedObjectContext {
    
    func execute<T>(
        _ action: @Sendable @escaping (NSManagedObjectContext) throws -> T
    ) throws -> T {
        defer {
            self.reset()
        }
        
        let value = try action(self)
        
        if hasChanges {
            try save()
        }
        
        return value
    }
}
