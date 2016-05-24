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
    
    public var dictionary: [Swift.String: JSON]? {
        guard case .object(let dict) = self else { return nil }
        return dict
    }
    
    public var array: [JSON]? {
        guard case .array(let arr) = self else { return nil }
        return arr
    }
    
    public var int: Int? {
        guard case .number(let number) = self else { return nil }
        guard case .integer(let jsonInt) = number else { return nil }
        return jsonInt
    }
    
    public var uint: UInt? {
        guard case .number(let number) = self else { return nil }
        switch number {
        case .integer(let int): return UInt(int)
        case .unsignedInteger(let uint): return uint
        default: return nil
        }
    }
    
    public var double: Double? {
        guard case .number(let number) = self else { return nil }
        switch number {
        case .double(let dbl): return dbl
        case .integer(let int): return Double(int)
        case .unsignedInteger(let uint): return Double(uint)
        }
    }
    
    public var string: Swift.String? {
        guard case .string(let str) = self else { return nil }
        return str
    }
    
    public var boolean: Bool? {
        guard case .boolean(let bool) = self else { return nil }
        return bool
    }
    
    public var null: NSNull? {
        guard case .null = self else { return nil }
        return NSNull()
    }
}

//Thanks for the inspiration for the following initializers, https://github.com/Zewo/JSON/blob/master/Source/JSON.swift

extension JSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

extension JSON: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(.integer(value))
    }
}

extension JSON: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(.double(value))
    }
}

extension JSON: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: Swift.String) {
        self = .string(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: Swift.String) {
        self = .string(value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}



