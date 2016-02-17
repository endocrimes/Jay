//
//  Reader.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

protocol Reader: class {
    func read(bytes: Int) throws -> [CChar]
}

let BufferCapacity = 512

extension Reader {
    
    /// Reads until 1) we run out of characters or 2) we detect the delimiter
    /// whichever happens first.
    func readUntilDelimiter(alreadyRead alreadyRead: [CChar], delimiter: String) throws -> ([CChar], [CChar]?) {
        
        var totalBuffer = alreadyRead
        let delimiterChars = delimiter.cchars()
        var lastReadCount = BufferCapacity
        
        while true {
            
            //test whether the incoming chars contain the delimiter
            let (head, tail) = totalBuffer.splitAround(delimiterChars)
            
            //if we have a tail, we found the delimiter in the buffer,
            //or if there's no more data to read
            //let's terminate and return the current split
            if tail != nil || lastReadCount < BufferCapacity {
                //end of transmission
                return (head, tail)
            }
            
            //read more characters from the reader
            let readChars = try self.read(BufferCapacity)
            lastReadCount = readChars.count
            
            //append received chars before delimiter
            totalBuffer.appendContentsOf(readChars)
        }
    }
}


class TestReader: Reader {
    
    var content: [CChar]
    
    init(content: String) {
        self.content = content.cchars()
    }
    
    func read(bytes: Int) throws -> [CChar] {
        
        precondition(bytes > 0)
        if self.content.isEmpty { throw Error("empty reader") }
        let toReadCount = min(bytes, self.content.count)
        let head = Array(self.content.prefix(toReadCount))
        self.content.removeFirst(toReadCount)
        return head
    }
}

