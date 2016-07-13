//
//  Extensions.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

extension JChar {
  
    /// Returns a `String` from an array of `JChar`s.
    /// - Throws: `Error` when parsing the string fails.
    public func string() throws -> String {
        return try [self].string()
    }
}

extension String {
    
    func chars() -> [JChar] {
        let chars = Array<JChar>(self.utf8)
        return chars
    }
    
    func char() -> JChar {
        let chars = self.chars()
        precondition(chars.count == 1)
        return chars.first!
    }
}

extension Collection where Iterator.Element == UInt8 {
  
    /// Returns a `String` from a collection with element `UInt8`.
    /// - Throws: `Error` when parsing the string fails.
    public func string() throws -> String {
        var utf = UTF8()
        var gen = self.makeIterator()
        var str = String()
        while true {
            switch utf.decode(&gen) {
            case .emptyInput: //we're done
                return str
            case .error: //error, can't describe what however
                throw Error.parseStringFromCharsFailed(Array(self))
            case .scalarValue(let unicodeScalar):
                str.append(unicodeScalar)
            }
        }
    }

    /// Splits string around a delimiter, returns the first subarray
    /// as the first return value (including the delimiter) and the rest
    /// as the second, if found (empty array if found at the end).
    /// Otherwise first array contains the original
    /// collection and the second is nil.
    func splitAround(delimiter: [JChar]) -> ([JChar], [JChar]?) {
        
        let orig = Array(self)
        let end = orig.endIndex
        let delimCount = delimiter.count
        
        var index = orig.startIndex
        while index+delimCount <= end {
            let cur = Array(orig[index..<index+delimCount])
            if cur == delimiter {
                //found
                let leading = Array(orig[0..<index+delimCount])
                let trailing = Array(orig.suffix(orig.count-leading.count))
                return (leading, trailing)
            } else {
                //not found, move index down
                index = index.advanced(by: 1)
            }
        }
        return (orig, nil)
    }
}

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
