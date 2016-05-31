//
//  Conversions.swift
//  Jay
//
//  Created by Honza Dvorsky on 5/16/16.
//
//

import Foundation

//Useful methods for easier manipulation of type-safe JSON

extension JSON {
  
    /// Returns the `JSON` as `[String: JSON]` if valid, else `nil`.
    public var dictionary: [Swift.String: JSON]? {
        guard case .object(let dict) = self else { return nil }
        return dict
    }
  
    /// Returns the `JSON` as `[JSON]` if valid, else `nil`.
    public var array: [JSON]? {
        guard case .array(let arr) = self else { return nil }
        return arr
    }
  
    /// Returns the `JSON` as an `Int` if valid, else `nil`.
    public var int: Int? {
        guard case .number(let number) = self else { return nil }
        guard case .integer(let jsonInt) = number else { return nil }
        return jsonInt
    }
  
    /// Returns the `JSON` as a `UInt` if valid, else `nil`.
    public var uint: UInt? {
        guard case .number(let number) = self else { return nil }
        switch number {
        case .integer(let int): return UInt(int)
        case .unsignedInteger(let uint): return uint
        default: return nil
        }
    }
  
    /// Returns the `JSON` as a `Double` if valid, else `nil`.
    public var double: Double? {
        guard case .number(let number) = self else { return nil }
        switch number {
        case .double(let dbl): return dbl
        case .integer(let int): return Double(int)
        case .unsignedInteger(let uint): return Double(uint)
        }
    }
  
    /// Returns the `JSON` as a `String` if valid, else `nil`.
    public var string: Swift.String? {
        guard case .string(let str) = self else { return nil }
        return str
    }
  
    /// Returns the `JSON` as a `Bool` if valid, else `nil`.
    public var boolean: Bool? {
        guard case .boolean(let bool) = self else { return nil }
        return bool
    }
  
    /// Returns the `JSON` as `NSNull` if valid, else `nil`.
    public var null: NSNull? {
        guard case .null = self else { return nil }
        return NSNull()
    }
}

//Thanks for the inspiration for the following initializers, https://github.com/Zewo/JSON/blob/master/Source/JSON.swift

extension JSON: BooleanLiteralConvertible {
  
    /// Create a `JSON` instance initialized to the provided `booleanLiteral`.
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

extension JSON: IntegerLiteralConvertible {
  
    /// Create a `JSON` instance initialized to the provided `integerLiteral`.
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(.integer(value))
    }
}

extension JSON: FloatLiteralConvertible {
  
    /// Create a `JSON` instance initialized to the provided `floatLiteral`.
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(.double(value))
    }
}

extension JSON: StringLiteralConvertible {
  
    /// Create a `JSON` instance initialized to the provided `unicodeScalarLiteral`.
    public init(unicodeScalarLiteral value: Swift.String) {
        self = .string(value)
    }
  
    /// Create a `JSON` instance initialized to the provided `extendedGraphemeClusterLiteral`.
    public init(extendedGraphemeClusterLiteral value: Swift.String) {
        self = .string(value)
    }
  
  
    /// Create a `JSON` instance initialized to the provided `stringLiteral`.
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}



