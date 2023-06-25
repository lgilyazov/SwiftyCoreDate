//
//  SortDescriptor.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import Foundation

public struct SortDescriptor: Equatable {
    let keyPathString: String
    var ascending = true
}

extension SortDescriptor {
    var object: NSSortDescriptor {
        .init(
            key: keyPathString,
            ascending: ascending
        )
    }
}

public extension SortDescriptor {
    init(
        keyPath: KeyPath<some Any, some Any>,
        ascending: Bool
    ) {
        self.keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        self.ascending = ascending
    }
}
