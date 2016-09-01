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

extension JChar {
    
    func controlCharacterHexString() -> [JChar] {
        var hex = String(self, radix: 16, uppercase: false).chars()
        
        //control chars are always only two hex characters, so we either got 1 or 2 chars,
        //pad to two
        if hex.count == 1 {
            hex = [Const.Zero] + hex
        }
        
        //and prepend with \u00, which is followed by our two hex bytes
        return [Const.Escape, Const.UnicodeStart, Const.Zero, Const.Zero] + hex
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
        var str = String.UnicodeScalarView()
        while true {
            switch utf.decode(&gen) {
            case .emptyInput: //we're done
                return String(str)
            case .error: //error, can't describe what however
                throw JayError.parseStringFromCharsFailed(Array(self))
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

