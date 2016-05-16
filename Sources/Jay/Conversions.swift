//
//  Conversions.swift
//  Jay
//
//  Created by Honza Dvorsky on 5/16/16.
//
//

import Foundation

public typealias JSON = JsonValue

//Useful methods for easier manipulation of type-safe JSON

extension JSON {
    
    public var dictionary: [Swift.String: JSON]? {
        guard case .Object(let dict) = self else { return nil }
        return dict
    }
    
    public var array: [JSON]? {
        guard case .Array(let arr) = self else { return nil }
        return arr
    }
    
    public var int: Int? {
        guard case .Number(let number) = self else { return nil }
        guard case .JsonInt(let jsonInt) = number else { return nil }
        return jsonInt
    }
    
    public var double: Double? {
        guard case .Number(let number) = self else { return nil }
        switch number {
        case .JsonDbl(let dbl): return dbl
        case .JsonInt(let int): return Double(int)
        }
    }
    
    public var string: Swift.String? {
        guard case .String(let str) = self else { return nil }
        return str
    }
    
    public var boolean: Bool? {
        guard case .Boolean(let bool) = self else { return nil }
        switch bool {
        case .True: return true
        case .False: return false
        }
    }
    
    public var null: NSNull? {
        guard case .Null = self else { return nil }
        return NSNull()
    }
}

//Thanks for the inspiration for the following initializers, https://github.com/Zewo/JSON/blob/master/Source/JSON.swift

extension JSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .Boolean(value ? .True : .False)
    }
}

extension JSON: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .Number(.JsonInt(value))
    }
}

extension JSON: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .Number(.JsonDbl(value))
    }
}

extension JSON: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: Swift.String) {
        self = .String(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: Swift.String) {
        self = .String(value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self = .String(value)
    }
}



