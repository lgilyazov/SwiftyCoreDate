//
//  File.swift
//  
//
//  Created by Lenar Gilyazov on 24.06.2023.
//

import Foundation

// MARK: - ConvertableValue + PrimitiveType

public extension ConvertableValue where Self: PrimitiveType {
    func encode() -> Self { self }
    static func decode(value: Self) throws -> Self { value }
}

// MARK: - ConvertableValue + Optional

public extension Optional where Wrapped: ConvertableValue {
    static func decode(_ anyValue: Any?) throws -> Wrapped? {
        try anyValue.flatMap { value in
            try Wrapped.decode(value)
        }
    }
}

// MARK: - ConvertableValue + RawValue

public extension RawRepresentable where RawValue: ConvertableValue {
    func encode() -> RawValue.ValueType {
        rawValue.encode()
    }

    static func decode(value: RawValue.ValueType) throws -> Self {
        let rawValue = try RawValue.decode(value: value)
        guard let value = Self(rawValue: rawValue) else {
            throw AttributeError.badInput(rawValue)
        }
        return value
    }
}

extension ConvertableValue {
    static func decode(_ some: Any?) throws -> Self {
        guard let value = some as? Self.ValueType else {
            throw AttributeError.badInput(some)
        }
        return try Self.decode(value: value)
    }
}

// MARK: - Int + PrimitiveType, ConvertableValue

extension Int: PrimitiveType, ConvertableValue {}

// MARK: - Int16 + PrimitiveType, ConvertableValue

extension Int16: PrimitiveType, ConvertableValue {}

// MARK: - Int32 + PrimitiveType, ConvertableValue

extension Int32: PrimitiveType, ConvertableValue {}

// MARK: - Int64 + PrimitiveType, ConvertableValue

extension Int64: PrimitiveType, ConvertableValue {}

// MARK: - Float + PrimitiveType, ConvertableValue

extension Float: PrimitiveType, ConvertableValue {}

// MARK: - Double + PrimitiveType, ConvertableValue

extension Double: PrimitiveType, ConvertableValue {}

// MARK: - Decimal + PrimitiveType, ConvertableValue

extension Decimal: PrimitiveType, ConvertableValue {}

// MARK: - Bool + PrimitiveType, ConvertableValue

extension Bool: PrimitiveType, ConvertableValue {}

// MARK: - Date + PrimitiveType, ConvertableValue

extension Date: PrimitiveType, ConvertableValue {}

// MARK: - String + PrimitiveType, ConvertableValue

extension String: PrimitiveType, ConvertableValue {}

// MARK: - Data + PrimitiveType, ConvertableValue

extension Data: PrimitiveType, ConvertableValue {}

// MARK: - UUID + PrimitiveType, ConvertableValue

extension UUID: PrimitiveType, ConvertableValue {}

// MARK: - URL + PrimitiveType, ConvertableValue

extension URL: PrimitiveType, ConvertableValue {}
