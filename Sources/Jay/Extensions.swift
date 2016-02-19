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

extension CollectionType where Generator.Element == UInt8 {
    
    public func string() throws -> String {
        var utf = UTF8()
        var gen = self.generate()
        var str = String()
        while true {
            switch utf.decode(&gen) {
            case .EmptyInput: //we're done
                return str
            case .Error: //error, can't describe what however
                throw Error.ParseStringFromCharsFailed(Array(self))
            case .Result(let unicodeScalar):
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
                index = index.successor()
            }
        }
        return (orig, nil)
    }
}

extension JsonValue: Equatable { }
func ==(lhs: JsonValue, rhs: JsonValue) -> Bool {
    switch (lhs, rhs) {
    case (.Null, .Null): return true
    case (.Boolean(let l), .Boolean(let r)): return l == r
    case (.String(let l), .String(let r)): return l == r
    case (.Array(let l), .Array(let r)): return l == r
    case (.Object(let l), .Object(let r)): return l == r
    case (.Number(let l), .Number(let r)):
        switch (l, r) {
        case (.JsonInt(let ll), .JsonInt(let rr)): return ll == rr
        case (.JsonDbl(let ll), .JsonDbl(let rr)): return ll == rr
        default: return false
        }
    default: return false
    }
}
