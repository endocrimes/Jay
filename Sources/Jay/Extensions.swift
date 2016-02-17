//
//  Extensions.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import Darwin //TODO: import GLibc

extension CChar {
    func string() throws -> String {
        return try [self].string()
    }
}

extension String {
    
    func cchars() -> [CChar] {
        return self.withCString { ptr in
            let count = Int(strlen(ptr))
            var idx = 0
            var out = Array<CChar>(count: count, repeatedValue: 0)
            while idx < count { out[idx] = ptr[idx]; idx += 1 }
            return out
        }
    }
}

extension CollectionType where Generator.Element == CChar {
    
    func string() throws -> String {
        let selfArray = Array(self) + [0]
        guard let string = String.fromCString(selfArray) else {
            throw Error("can't parse \(self)")
        }
        return string
    }

    /// Splits string around a delimiter, returns the first subarray
    /// as the first return value (including the delimiter) and the rest
    /// as the second, if found (empty array if found at the end).
    /// Otherwise first array contains the original
    /// collection and the second is nil.
    func splitAround(delimiter: [CChar]) -> ([CChar], [CChar]?) {
        
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

