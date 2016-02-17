//
//  Reader.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

protocol Reader {
    
    // Returns the currently pointed-at char
    func curr() -> CChar

    // Moves cursor to the next char
    mutating func next()
    
    // Returns the next character
    func peek() -> CChar?
    
    // Returns `true` if all characters have been read 
    func isDone() -> Bool
}

extension Reader {
    
    // Consumes all contiguous whitespace and returns # of consumed chars
    mutating func consumeWhitespace() -> Int {
        var counter = 0
        while !self.isDone() {
            let char = self.curr()
            if Const.Whitespace.contains(char) {
                //consume
                counter += 1
                self.next()
            } else {
                //non-whitespace, return
                break
            }
        }
        return counter
    }
    
    // Iterates both readers and checks that characters match until
    // a) expectedReader runs out of characters -> great! all match
    // b) self runs out of characters -> bad, no match!
    // c) we encounter a difference -> bad, no match!
    mutating func stopAtFirstDifference(expectedReader r: Reader) throws -> Reader {
        return self
    }
}


