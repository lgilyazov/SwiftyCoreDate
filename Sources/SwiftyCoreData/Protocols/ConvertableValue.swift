//
//  ConvertableValue.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import Foundation

public protocol ConvertableValue {
    associatedtype ValueType: PrimitiveType
    func encode() -> ValueType
    static func decode(value: ValueType) throws -> Self
}
