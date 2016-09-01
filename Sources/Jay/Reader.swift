//
//  Reader.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

public protocol Reader: class {
    
    // Returns the currently pointed-at char
    func curr() -> UInt8

    // Moves cursor to the next char
    func next() throws
    
    // Returns `true` if all characters have been read 
    func isDone() -> Bool
    
    // Finish parsing when valid JSON object has been parsed?
    // Return true: for streaming parsers that never end, so that we don't
    //              hang on waiting for more data even though a valid JSON
    //              object has been parsed.
    // Return false: for parsers that already have all data in memory, stricter
    //               mode that ensures that no invalid trailing bytes have been
    //               sent after the valid JSON object.
    func finishParsingWhenValid() -> Bool
}

//@discardableResult
//func consumeWhitespace<R: Reader>(_ reader: R) throws -> Int {
//    var counter = 0
//    while !reader.isDone() {
//        let char = reader.curr()
//        if Const.Whitespace.contains(char) {
//            //consume
//            counter += 1
//            try reader.next()
//        } else {
//            //non-whitespace, return
//            break
//        }
//    }
//    return counter
//}
//
//func ensureNotDone<R: Reader>(_ reader: R) throws {
//    if reader.isDone() {
//        throw JayError.unexpectedEnd(reader)
//    }
//}
//
//func nextAndCheckNotDone<R: Reader>(_ reader: R) throws {
//    try reader.next()
//    try reader.ensureNotDone()
//}

extension Reader {
    
    func readNext(_ next: Int) throws -> [JChar] {
        try ensureNotDone()
        var buff = [JChar]()
        while buff.count < next {
            buff.append(self.curr())
            try nextAndCheckNotDone()
        }
        return buff
    }
    
    func ensureNotDone() throws {
        if isDone() {
            throw JayError.unexpectedEnd(self)
        }
    }
    
    func nextAndCheckNotDone() throws {
        try next()
        try ensureNotDone()
    }
    
    // Consumes all contiguous whitespace and returns # of consumed chars
    @discardableResult
    func consumeWhitespace() throws -> Int {
        var counter = 0
        while !self.isDone() {
            let char = self.curr()
            if Const.Whitespace.contains(char) {
                //consume
                counter += 1
                try self.next()
            } else {
                //non-whitespace, return
                break
            }
        }
        return counter
    }
    
    // Gathers all bytes until `terminator` is found, returns everything except the terminator
    // the cursor is right after the terminator
    // If the end of `self` is encountered without finding `terminator`, `foundTerminator` is false
    func collectUntil(terminator: [JChar]) throws -> (collected: [JChar], foundTerminator: Bool) {
        var collected: [UInt8] = []
        var nextBuffer = CircularBuffer<UInt8>(size: terminator.count, defaultValue: 0)
        while !isDone() {
            let char = curr()
            nextBuffer.append(char)
            collected.append(char)
            if nextBuffer == terminator {
                //remove the terminator from collected
                try next()
                return (Array(collected.dropLast(terminator.count)), true)
            }
            try next()
        }
        return (collected, false)
    }
    
    // Iterates both readers and checks that characters match until
    // a) expectedReader runs out of characters -> great! all match
    // b) self runs out of characters -> bad, no match!
    // c) we encounter a difference -> bad, no match!
    func stopAtFirstDifference<R: Reader>(_ other: R) throws {
        
        while true {
            
            if other.isDone() {
                //a) all matched, return
                return
            }
            
            if isDone() {
                //b) no match
                throw JayError.mismatch(self, other)
            }

            let charSelf = curr()
            let charOther = other.curr()
            guard charSelf == charOther else {
                //c) no match
                throw JayError.mismatch(self, other)
            }
            
            try next()
            try other.next()
        }
    }
}

struct CircularBuffer<T: Equatable> {
    
    let size: Int
    private var _cursor: Int = 0
    private var _storage: [T]
    
    init(size: Int, defaultValue: T) {
        self.size = size
        self._storage = Array(repeating: defaultValue, count: size)
    }
    
    mutating func append(_ element: T) {
        _storage[_cursor] = element
        _cursor = (_cursor + 1) % size
    }
    
    static func ==(lhs: CircularBuffer<T>, rhs: [T]) -> Bool {
        let size = lhs.size
        guard lhs.size == rhs.count else { return false }
        let offset = lhs._cursor
        for i in 0..<size {
            guard lhs._storage[(i + offset) % size] == rhs[i] else { return false }
        }
        return true
    }
}

