//
//  TestUtils.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Jay

extension JSON: Equatable { }
public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null): return true
    case (.boolean(let l), .boolean(let r)): return l == r
    case (.string(let l), .string(let r)): return l == r
    case (.array(let l), .array(let r)): return l == r
    case (.object(let l), .object(let r)): return l == r
    case (.number(let l), .number(let r)):
        switch (l, r) {
        case (.integer(let ll), .integer(let rr)): return ll == rr
        case (.unsignedInteger(let ll), .unsignedInteger(let rr)): return ll == rr
        case (.double(let ll), .double(let rr)): return ll == rr
        default: return false
        }
    default: return false
    }
}

func ensureNull(_ val: JSON) {
    XCTAssertEqual(val, JSON.null)
}

func ensureComment(_ val: [JChar], exp: String, file: StaticString = #file, line: UInt = #line) throws {
    XCTAssertEqual(try val.string(), exp)
}

func ensureBool(_ val: JSON, exp: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.boolean(exp))
}

func ensureArray(_ val: JSON, exp: [JSON], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.array(exp))
}

func ensureNumber(_ val: JSON, exp: JSON.Number, file: StaticString = #file, line: UInt = #line) {
    switch val {
    case .number(let num):
        
        switch (num, exp) {
        case (.double(let l), .double(let r)):
            XCTAssertEqualWithAccuracy(r, l, accuracy: 1e-10)
        case (.integer(let l), .integer(let r)):
            XCTAssertEqual(l, r)
        case (.unsignedInteger(let l), .unsignedInteger(let r)):
            XCTAssertEqual(l, r)
        default: XCTFail()
        }
    default: XCTFail()
    }
}

func ensureString(_ val: JSON, exp: String, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.string(exp))
}

func ensureObject(_ val: JSON, exp: [String: JSON], file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(val, JSON.object(exp))
}

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

extension JSON: ExpressibleByBooleanLiteral {
    
    /// Create a `JSON` instance initialized to the provided `booleanLiteral`.
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    
    /// Create a `JSON` instance initialized to the provided `integerLiteral`.
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(.integer(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    
    /// Create a `JSON` instance initialized to the provided `floatLiteral`.
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(.double(value))
    }
}

extension JSON: ExpressibleByStringLiteral {
    
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

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var items: [String: JSON] = [:]
        for pair in elements {
            items[pair.0] = pair.1
        }
        self = .object(items)
    }
}




