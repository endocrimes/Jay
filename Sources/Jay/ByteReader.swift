//
//  ByteReader.swift
//  Jay
//
//  Created by Honza Dvorsky on 2/17/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

class ByteReader: Reader {
    
    private let content: [JChar]
    private var cursor: Array<JChar>.Index
    
    init(content: [JChar]) {
        self.content = content
        self.cursor = self.content.startIndex
    }
    
    func next() {
        precondition(!self.isDone())
        self.cursor = self.cursor.advanced(by: 1)
    }
    
    func curr() -> JChar {
        precondition(!self.isDone())
        return self.content[self.cursor]
    }
    
    func isDone() -> Bool {
        return self.cursor == self.content.endIndex
    }
    
    func finishParsingWhenValid() -> Bool {
        //let's make sure no invalid trailing characters are present
        return false
    }
    
    convenience init(content: String) {
        self.init(content: content.chars())
    }
}
