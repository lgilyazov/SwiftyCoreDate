//
//  AttributeError.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import Foundation

enum AttributeError: Swift.Error {
    case failedToDecode(for: String, model: String)
    case failedToEncode(for: String, model: String)
    case failedToEncodeRelation(for: String, model: String)
    case badInput(Any?)
}
